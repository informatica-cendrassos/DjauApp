import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/models/alumne.dart';
import 'package:cendrassos/models/perfil.dart';
import 'package:cendrassos/models/login.dart';
import 'package:cendrassos/models/sortida.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/services/storage.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:flutter/foundation.dart';

import '../api/exceptions.dart';

class LoginResult {
  DjauStatus isLogged;
  String errorType;
  String errorMessage;

  LoginResult(this.isLogged, this.errorType, this.errorMessage);
}

enum DjauStatus { loaded, error, withoutUser, disabled }

class DjauModel with ChangeNotifier {
  static const bool _debugLogsEnabled = kDebugMode;

  final NotificacionsRepository _repository;
  final DjauSecureStorage _storage;
  final DjauLocalStorage _prefs;

  void _logDebug(String message) {
    if (_debugLogsEnabled) {
      debugPrint(message);
    }
  }

  // Estat actual
  DjauStatus _isLogged = DjauStatus.withoutUser;
  // Missatge d'error si no hem entrat
  String errorMessage = "";
  String errorType = "";

  // Credencials d'accés a l'aplicació
  Tutor tutor = Tutor("", "", "", "");

  // Alumne actual i darrer que s'ha fet servir
  Alumne alumne = Alumne(0, "", "");

  /// Constructor amb dependency injection
  /// Permet testejar injectant mocks per a repository, storage, i prefs
  DjauModel({
    NotificacionsRepository? repository,
    DjauSecureStorage? storage,
    DjauLocalStorage? prefs,
  })  : _repository = repository ?? NotificacionsRepository(),
        _storage = storage ?? DjauSecureStorage(),
        _prefs = prefs ?? DjauLocalStorage();

  bool isLogged() => _isLogged == DjauStatus.loaded;
  bool isError() => _isLogged == DjauStatus.error;

  void _setErrorFromAppException(AppException exception) {
    _isLogged = DjauStatus.error;
    final prefix = exception.prefix().trim();
    final message = exception.message().trim();
    errorType = prefix.isEmpty ? defaultErrorMessage : prefix;
    errorMessage = message.isEmpty ? undefinedError : message;
  }

  void _setUnexpectedError(Object exception) {
    _isLogged = DjauStatus.error;
    errorType = defaultErrorMessage;
    errorMessage = undefinedError;
    _logDebug('Unexpected login error: $exception');
  }

  Future<void> _syncTutorSessionFromRepository() async {
    _repository.syncTutorSession(tutor);
    if (tutor.username.isEmpty) {
      return;
    }
    try {
      await _storage.saveTutor(tutor);
    } catch (storageException) {
      _logDebug('Session persistence after refresh failed: $storageException');
    }
  }

  /// Entrar en el sistema a través d'usuari [username] i
  /// contrasenya [password]. Es fa servir quan s'intenta fer login contra
  /// el servidor
  ///
  /// Si tot va bé carrega la variable `tutor` i si no, posa l'estat en error
  Future<LoginResult> login(String username, String password) async {
    try {
      final response = await _repository.login(Login(username, password));
      // Crea les dades del tutor a partir de les credencials i el token que ens ha donat el servidor
      tutor = Tutor.fromNow(
        username,
        password,
        response.accessToken,
        response.refreshToken,
      );

      _isLogged = DjauStatus.loaded;
      errorMessage = "";
      errorType = "";
      try {
        await _prefs.setLastLogin(username);
        await _storage.saveTutor(tutor);
      } catch (storageException) {
        // Si falla la persistència local, mantenim el login com a vàlid.
        _logDebug('Login local persistence error: $storageException');
      }
    } on AppException catch (f) {
      _setErrorFromAppException(f);
    } catch (e) {
      _setUnexpectedError(e);
    }
    notifyListeners();
    return LoginResult(_isLogged, errorType, errorMessage);
  }

  // Intentar fer login amb les credencials que hi ha emmagatzemades al sistema.
  //Es fa servir quan es vol carregar l'últim usuari que ha entrat a l'aplicació
  Future<LoginResult> loginWithStoredCredentials() async {
    try {
      final username = await _prefs.getLastLogin();
      if (username == null) {
        return LoginResult(DjauStatus.withoutUser, "", "");
      }

      final tutor = await _storage.loadTutor(username);
      if (tutor == null) {
        await _prefs.clearLastLogin();
        await _prefs.clearLastAlumne();
        return LoginResult(DjauStatus.withoutUser, "", "");
      }

      this.tutor = tutor;
      _repository.setTutorSession(tutor);
      _isLogged = DjauStatus.loaded;
      errorType = "";
      errorMessage = "";
      notifyListeners();
      return LoginResult(_isLogged, errorType, errorMessage);
    } catch (e) {
      _setUnexpectedError(e);
      notifyListeners();
      return LoginResult(_isLogged, errorType, errorMessage);
    }
  }

  /// Carrega l'alumne amb l'ID especificat.
  /// Es fa servir per carregar la variable `alumne` quan ja s'ha fet login i es vol
  /// carregar un altre alumne
  Future loadAlumne(int id) async {
    // Cridar a la llista d'alumnes associats
    var alumnes = await _repository.getAlumnesList();
    await _syncTutorSessionFromRepository();
    var alumneTrobat = alumnes.any((a) => a.id == id);
    if (!alumneTrobat) {
      // No es pot carregar l'alumne perquè no està associat al tutor que ha entrat al sistema
      throw Exception("L'alumne amb ID $id no està associat al tutor");
    }
    alumne = alumnes.firstWhere((a) => a.id == id);
    _prefs.setLastAlumne(alumne.id);
    notifyListeners();
  }

  /// Defineix quina és la pantalla inicial en iniciar el programa
  /// - No hi ha tutor -> Login (0)
  /// - Hi ha tutor (1) -> Carregar l'últim alumne
  Future<int> determineInitialPage() async {
    // Reinicia l'estat temporal d'error per evitar missatges stale en Retry.
    _isLogged = DjauStatus.withoutUser;
    errorType = "";
    errorMessage = "";

    try {
      var username = await _prefs.getLastLogin();
      if (username == null) return 0;
      return 1;
    } catch (e) {
      _isLogged = DjauStatus.error;
      errorType = defaultErrorMessage;
      errorMessage = errorCarregant;
      _logDebug('Error determining initial page: $e');
      return 0;
    }
  }

  // Comprova si hi ha un alumne per defecte que es pugui carregar
  Future<bool> hasDefaultAlumne() async {
    var idAlumne = await _prefs.getLastAlumne();
    return idAlumne != null;
  }

  /// Carrega l'alumne que havia entrat per darrera vegada.
  /// La variable `alumne` s'inicialitza amb les seves dades o bé es posa
  /// el sistema en estat d'error.
  ///
  /// L'alumne que va entrar per darrera vegada es defineix
  /// a `SetDefaultAlumne`
  Future loadDefaultAlumne() async {
    var idAlumne = await _prefs.getLastAlumne();
    if (idAlumne != null) {
      await loadAlumne(idAlumne);
    } else {
      throw Exception("No hi ha dades de l'alumne per defecte");
    }
  }

  /// Obtenir una llista amb els noms dels alumnes i el seu id.
  /// Cal per poder llistar els noms dels alumnes a més del seu
  /// id
  Future<Map<int, String>> getAlumnesMap() async {
    var resultat = <int, String>{};
    var alumnes = await _repository.getAlumnesList();
    await _syncTutorSessionFromRepository();
    for (var alumne in alumnes) {
      resultat[alumne.id] = alumne.nomComplet();
    }
    return resultat;
  }

  void logout() {
    notifyListeners();
  }

  /// Carrega el perfil de l'usuari que està actiu en aquest moment
  Future<Perfil> loadPerfil() async {
    final response = await _repository.getProfile(alumne.id);
    await _syncTutorSessionFromRepository();
    return response;
  }

  // Carregar el detalla de la sortida
  Future<Sortida> loadSortida(int id, int alumneId) async {
    final response = await _repository.getSortida(id, alumneId);
    await _syncTutorSessionFromRepository();
    return response;
  }
}
