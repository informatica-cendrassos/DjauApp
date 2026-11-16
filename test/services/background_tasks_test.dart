import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/services/background_tasks.dart';
import 'package:cendrassos/services/notifications_manager.dart';
import 'package:cendrassos/services/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _SessionStorage extends DjauSecureStorage {
  _SessionStorage(this.tutor);

  final Tutor? tutor;

  @override
  Future<Tutor?> loadCurrentTutor() async => tutor;
}

class _RecordingNotificationManager extends NotificationManager {
  int initializationCount = 0;

  @override
  Future<void> initNotificationManager(
      Function(String?) selectNotification) async {
    initializationCount++;
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
