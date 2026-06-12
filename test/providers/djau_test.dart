import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/api/login_response.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/alumne.dart';
import 'package:cendrassos/models/login.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/services/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<NotificacionsRepository>(),
  MockSpec<DjauSecureStorage>(),
  MockSpec<DjauLocalStorage>(),
])
import 'djau_test.mocks.dart';

void main() {
  group('DjauModel', () {
    late MockNotificacionsRepository mockRepository;
    late MockDjauSecureStorage mockSecureStorage;
    late MockDjauLocalStorage mockLocalStorage;
    late DjauModel djauModel;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockRepository = MockNotificacionsRepository();
      mockSecureStorage = MockDjauSecureStorage();
      mockLocalStorage = MockDjauLocalStorage();

      when(mockSecureStorage.saveTutor(any)).thenAnswer((_) async {});
      when(mockSecureStorage.loadTutor(any)).thenAnswer((_) async => null);
      when(mockSecureStorage.deleteTutor(any)).thenAnswer((_) async {});

      when(mockLocalStorage.getLastLogin()).thenAnswer((_) async => null);
      when(mockLocalStorage.setLastLogin(any)).thenAnswer((_) async {});
      when(mockLocalStorage.clearLastLogin()).thenAnswer((_) async {});
      when(mockLocalStorage.getLastAlumne()).thenAnswer((_) async => null);
      when(mockLocalStorage.setLastAlumne(any)).thenAnswer((_) async {});
      when(mockLocalStorage.clearLastAlumne()).thenAnswer((_) async {});

      djauModel = DjauModel(
        repository: mockRepository,
        storage: mockSecureStorage,
        prefs: mockLocalStorage,
      );
    });

    group('login', () {
      test('sets loaded status and tutor data on success', () async {
        when(mockRepository.login(any)).thenAnswer(
          (_) async => LoginResponse(accessToken: 'token_123'),
        );

        final result = await djauModel.login('user', 'pass');

        expect(result.isLogged, DjauStatus.loaded);
        expect(result.errorType, isEmpty);
        expect(result.errorMessage, isEmpty);
        expect(djauModel.tutor.username, 'user');
        expect(djauModel.tutor.password, 'pass');
        expect(djauModel.tutor.token, 'token_123');
        verify(mockLocalStorage.setLastLogin('user')).called(1);
        verify(mockSecureStorage.saveTutor(any)).called(1);
      });

      test('keeps login loaded if local persistence fails', () async {
        when(mockRepository.login(any)).thenAnswer(
          (_) async => LoginResponse(accessToken: 'token_123'),
        );
        when(mockLocalStorage.setLastLogin(any))
            .thenThrow(Exception('prefs fail'));

        final result = await djauModel.login('user', 'pass');

        expect(result.isLogged, DjauStatus.loaded);
        expect(result.errorType, isEmpty);
        expect(result.errorMessage, isEmpty);
      });

      test('returns auth error info on AppException', () async {
        when(mockRepository.login(any)).thenThrow(
          UnauthorisedException('Credencials incorrectes'),
        );

        final result = await djauModel.login('bad', 'bad');

        expect(result.isLogged, DjauStatus.error);
        expect(result.errorType, notAuthorizedExceptionMessage.trim());
        expect(result.errorMessage, 'Credencials incorrectes');
      });

      test('returns generic fallback on unexpected exception', () async {
        when(mockRepository.login(any)).thenThrow(Exception('boom'));

        final result = await djauModel.login('user', 'pass');

        expect(result.isLogged, DjauStatus.error);
        expect(result.errorType, defaultErrorMessage);
        expect(result.errorMessage, undefinedError);
      });

      test('clears previous error after subsequent successful login', () async {
        when(mockRepository.login(argThat(isA<Login>().having(
          (l) => l.username,
          'username',
          'first',
        )))).thenThrow(UnauthorisedException('Denied'));
        when(mockRepository.login(argThat(isA<Login>().having(
          (l) => l.username,
          'username',
          'second',
        )))).thenAnswer((_) async => LoginResponse(accessToken: 'ok'));

        final failed = await djauModel.login('first', 'x');
        final success = await djauModel.login('second', 'y');

        expect(failed.isLogged, DjauStatus.error);
        expect(success.isLogged, DjauStatus.loaded);
        expect(success.errorType, isEmpty);
        expect(success.errorMessage, isEmpty);
      });
    });

    group('loginWithStoredCredentials', () {
      test('returns withoutUser if no last login exists', () async {
        when(mockLocalStorage.getLastLogin()).thenAnswer((_) async => null);

        final result = await djauModel.loginWithStoredCredentials();

        expect(result.isLogged, DjauStatus.withoutUser);
        verifyNever(mockRepository.login(any));
      });

      test('clears stale local login if tutor record is missing', () async {
        when(mockLocalStorage.getLastLogin()).thenAnswer((_) async => 'saved');
        when(mockSecureStorage.loadTutor('saved'))
            .thenAnswer((_) async => null);

        final result = await djauModel.loginWithStoredCredentials();

        expect(result.isLogged, DjauStatus.withoutUser);
        verify(mockLocalStorage.clearLastLogin()).called(1);
        verify(mockLocalStorage.clearLastAlumne()).called(1);
      });

      test('attempts login with stored tutor credentials', () async {
        when(mockLocalStorage.getLastLogin()).thenAnswer((_) async => 'saved');
        when(mockSecureStorage.loadTutor('saved')).thenAnswer(
          (_) async => Tutor('saved', 'pw', 'token_saved', 'refresh_saved'),
        );

        final result = await djauModel.loginWithStoredCredentials();

        expect(result.isLogged, DjauStatus.loaded);
        expect(djauModel.tutor.username, 'saved');
        expect(djauModel.tutor.token, 'token_saved');
        expect(djauModel.tutor.refreshToken, 'refresh_saved');
        verifyNever(mockRepository.login(any));
      });
    });

    group('determineInitialPage', () {
      test('returns 0 when no stored login exists', () async {
        when(mockLocalStorage.getLastLogin()).thenAnswer((_) async => null);

        final page = await djauModel.determineInitialPage();

        expect(page, 0);
      });

      test('returns 1 when stored login exists', () async {
        when(mockLocalStorage.getLastLogin()).thenAnswer((_) async => 'saved');

        final page = await djauModel.determineInitialPage();

        expect(page, 1);
      });

      test('sets error state and returns 0 on storage exception', () async {
        when(mockLocalStorage.getLastLogin())
            .thenThrow(Exception('prefs broken'));

        final page = await djauModel.determineInitialPage();

        expect(page, 0);
        expect(djauModel.isError(), isTrue);
        expect(djauModel.errorType, defaultErrorMessage);
        expect(djauModel.errorMessage, errorCarregant);
      });

      test('clears stale auth error before evaluating initial route', () async {
        when(mockRepository.login(any)).thenThrow(
          UnauthorisedException('Denied'),
        );
        when(mockLocalStorage.getLastLogin()).thenAnswer((_) async => null);

        final failed = await djauModel.login('bad', 'bad');
        final page = await djauModel.determineInitialPage();

        expect(failed.isLogged, DjauStatus.error);
        expect(page, 0);
        expect(djauModel.isError(), isFalse);
        expect(djauModel.errorType, isEmpty);
        expect(djauModel.errorMessage, isEmpty);
      });
    });

    group('loadAlumne', () {
      test('throws when requested alumne is not associated with tutor', () {
        when(mockRepository.getAlumnesList())
            .thenAnswer((_) async => <Alumne>[]);

        expect(() => djauModel.loadAlumne(999), throwsException);
      });

      test('syncs refreshed session back into tutor after alumnes load',
          () async {
        djauModel.tutor = Tutor('saved', 'pw', 'old_token', 'old_refresh');
        when(mockRepository.getAlumnesList()).thenAnswer(
          (_) async => <Alumne>[Alumne(7, 'Nom', 'Cognoms')],
        );
        when(mockRepository.syncTutorSession(any)).thenAnswer((invocation) {
          final tutor = invocation.positionalArguments.first as Tutor;
          tutor.token = 'new_token';
          tutor.refreshToken = 'new_refresh';
        });

        await djauModel.loadAlumne(7);

        expect(djauModel.tutor.token, 'new_token');
        expect(djauModel.tutor.refreshToken, 'new_refresh');
        verify(mockSecureStorage.saveTutor(djauModel.tutor)).called(1);
      });
    });
  });
}
