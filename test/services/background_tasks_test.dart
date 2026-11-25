import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/models/alumne.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/services/background_tasks.dart';
import 'package:cendrassos/services/notifications_manager.dart';
import 'package:cendrassos/services/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _SessionStorage extends DjauSecureStorage {
  _SessionStorage(this.tutor);

  final Tutor? tutor;
  final savedTutors = <Tutor>[];
  bool failSaving = false;

  @override
  Future<Tutor?> loadCurrentTutor() async => tutor;

  @override
  Future<void> saveTutor(Tutor tutor) async {
    if (failSaving) throw StateError('storage failure');
    savedTutors.add(tutor);
  }
}

class _RecordingNotificationManager extends NotificationManager {
  int initializationCount = 0;

  @override
  Future<void> initNotificationManager(
      Function(String?) selectNotification) async {
    initializationCount++;
  }
}

class _FailingRepository extends NotificacionsRepository {
  @override
  Future<List<Alumne>> getAlumnesList() async {
    setCurrentToken('new');
    throw FetchDataException('API failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackgroundTask', () {
    test('skips notification initialization when the session is absent',
        () async {
      for (final tutor in [null, Tutor('', '', '', '')]) {
        final manager = _RecordingNotificationManager();
        final task = BackgroundTask(storage: _SessionStorage(tutor))
          ..manager = manager;
        await task.checkNewNotificacions((_) {});
        expect(manager.initializationCount, 0);
      }
    });

    test('retries a failed GET and completes when the connection recovers',
        () async {
      var requests = 0;
      final task = BackgroundTask(
          storage: _SessionStorage(Tutor('user', 'pass', 'access', 'refresh')))
        ..manager = _RecordingNotificationManager()
        ..api = NotificacionsRepository(
          httpClient: MockClient((request) async {
            requests++;
            if (requests == 1) throw http.ClientException('connection reset');
            return http.Response('[]', 200);
          }),
        );

      await task.checkNewNotificacions((_) {});
      expect(requests, 2);
    });

    test('stops retrying a GET after the configured limit', () async {
      var requests = 0;
      final task = BackgroundTask(
          storage: _SessionStorage(Tutor('user', 'pass', 'access', 'refresh')))
        ..manager = _RecordingNotificationManager()
        ..api = NotificacionsRepository(
          httpClient: MockClient((request) async {
            requests++;
            throw http.ClientException('connection reset');
          }),
        );

      await expectLater(
        task.checkNewNotificacions((_) {}),
        throwsA(isA<FetchDataException>()),
      );
      expect(requests, 4);
    });

    for (final failure in ['client', 'server']) {
      test('does not retry an uncertain refresh $failure failure', () async {
        var pupilsRequests = 0;
        var refreshRequests = 0;
        final task = BackgroundTask(
            storage: _SessionStorage(Tutor('user', 'pass', 'old', 'refresh')))
          ..manager = _RecordingNotificationManager()
          ..api = NotificacionsRepository(
            httpClient: MockClient((request) async {
              if (request.url.path.contains('api-token-refresh')) {
                refreshRequests++;
                if (failure == 'client') {
                  throw http.ClientException('connection closed');
                }
                return http.Response('{"detail":"server error"}', 500);
              }
              pupilsRequests++;
              return http.Response('{"detail":"expired"}', 401);
            }),
          );

        await expectLater(
          task.checkNewNotificacions((_) {}),
          throwsA(isA<FetchDataException>()
              .having((error) => error.retryable, 'retryable', isFalse)),
        );
        expect(pupilsRequests, 1);
        expect(refreshRequests, 1);
      });
    }

    test('saves refreshed tokens when the notification check retries and fails',
        () async {
      final storage = _SessionStorage(Tutor('user', 'pass', 'old', 'refresh'));
      final task = BackgroundTask(storage: storage)
        ..manager = _RecordingNotificationManager()
        ..api = NotificacionsRepository(
          httpClient: MockClient((request) async {
            if (request.url.path.contains('alumnes_associats')) {
              return http.Response(
                  '[{"id":1,"nom":"Nom","cognoms":"Cognoms"}]', 200);
            }
            if (request.url.path.contains('api-token-refresh')) {
              return http.Response(
                  '{"access":"new","refresh":"new-refresh"}', 200);
            }
            if (request.headers['Authorization'] == 'Bearer old') {
              return http.Response('{"detail":"expired"}', 401);
            }
            expect(request.headers['Authorization'], 'Bearer new');
            return http.Response('{"detail":"server error"}', 500);
          }),
        );

      await task.checkNewNotificacions((_) {});
      expect(storage.savedTutors, hasLength(1));
      expect(storage.savedTutors.single.token, 'new');
      expect(storage.savedTutors.single.refreshToken, 'new-refresh');
    });

    test('propagates storage failure after a successful refresh', () async {
      final storage = _SessionStorage(Tutor('user', 'pass', 'old', 'refresh'))
        ..failSaving = true;
      final task = BackgroundTask(storage: storage)
        ..manager = _RecordingNotificationManager()
        ..api = NotificacionsRepository(
          httpClient: MockClient((request) async {
            if (request.url.path.contains('api-token-refresh')) {
              return http.Response(
                  '{"access":"new","refresh":"new-refresh"}', 200);
            }
            if (request.headers['Authorization'] == 'Bearer old') {
              return http.Response('{"detail":"expired"}', 401);
            }
            return http.Response('[]', 200);
          }),
        );

      await expectLater(
        task.checkNewNotificacions((_) {}),
        throwsA(isA<StateError>()),
      );
      expect(storage.savedTutors, isEmpty);
    });

    test('reports a storage failure without hiding the original API failure',
        () async {
      final storage = _SessionStorage(Tutor('user', 'pass', 'old', 'refresh'))
        ..failSaving = true;
      final task = BackgroundTask(storage: storage)
        ..manager = _RecordingNotificationManager()
        ..api = _FailingRepository();
      final messages = <String>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) messages.add(message);
      };
      try {
        await expectLater(
          task.checkNewNotificacions((_) {}),
          throwsA(isA<FetchDataException>()),
        );
      } finally {
        debugPrint = previousDebugPrint;
      }

      expect(
        messages.any((message) => message
            .startsWith('[BackgroundFetch] Failed to save refreshed session')),
        isTrue,
      );
      expect(messages.join('\n'), isNot(contains('storage failure')));
    });
  });

  group('runBackgroundFetch', () {
    const channel =
        MethodChannel('com.transistorsoft/flutter_background_fetch/methods');
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('finishes after successful work', () async {
      await runBackgroundFetch('success', () async {});

      expect(calls.map((call) => (call.method, call.arguments)),
          [('finish', 'success')]);
    });

    test('logs failure without its message and still finishes', () async {
      final messages = <String>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) messages.add(message);
      };
      try {
        await runBackgroundFetch('failure', () async {
          throw Exception('sensitive details');
        });
      } finally {
        debugPrint = previousDebugPrint;
      }

      expect(calls.map((call) => (call.method, call.arguments)),
          [('finish', 'failure')]);
      expect(
        messages.any(
            (message) => message.startsWith('[BackgroundFetch] Task failed (')),
        isTrue,
      );
      expect(messages.join('\n'), isNot(contains('sensitive details')));
    });

    test('surfaces failure to report completion', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'finish_failed');
      });

      await expectLater(
        runBackgroundFetch('failure', () async {}),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
