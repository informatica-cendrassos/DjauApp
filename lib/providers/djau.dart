import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/models/alumne.dart';
import 'package:cendrassos/models/perfil.dart';
import 'package:cendrassos/models/login.dart';
import 'package:cendrassos/models/sortida.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/services/storage.dart';
import 'package:flutter/material.dart';

import '../api/exceptions.dart';

class LoginResult {
  DjauStatus isLogged;
  String errorType;
  String errorMessage;

  LoginResult(this.isLogged, this.errorType, this.errorMessage);
}

enum DjauStatus { loaded, error, withoutUser, disabled }

class DjauModel with ChangeNotifier {
  final NotificacionsRepository _repository = NotificacionsRepository();
  final DjauSecureStorage _storage = DjauSecureStorage();
  final DjauLocalStorage _prefs = DjauLocalStorage();

  // Estat actual
  DjauStatus _isLogged = DjauStatus.withoutUser;
  // Missatge d'error si no hem entrat
  String errorMessage = "";
  String errorType = "";

  // Credencials d'accés a l'aplicació
  Tutor tutor = Tutor("", "", "", "");

  // Alumne actual i darrer que s'ha fet servir
  Alumne alumne = Alumne(0, "", "");

  bool isLogged() => _isLogged == DjauStatus.loaded;
  bool isError() => _isLogged == DjauStatus.error;

  /// Entrar en el sistema a través d'usuari [username] i
  /// contrasenya [password]. Es fa servir quan s'intenta fer login contra
  /// el servidor
  ///
  /// Si tot va bé carrega la variable `tutor` i si no, posa l'estat en error
  Future<LoginResult> login(String username, String password) async {
    try {
      final response = await _repository.login(Login(username, password));
      // Crea les dades del tutor a partir de les credencials i el token que ens ha donat el servidor
      tutor = Tutor.fromNow(username, password, response.accessToken);

      _isLogged = DjauStatus.loaded;
      errorMessage = "";
      errorType = "";
      _prefs.setLastLogin(username);
      await _storage.saveTutor(tutor);
    } on AppException catch (f) {
      _isLogged = DjauStatus.error;
      errorType = f.prefix();
      errorMessage = f.message();
    } catch (e) {
      _isLogged = DjauStatus.error;
      errorType = "ERROR";
      errorMessage = e.toString();
    }
    notifyListeners();
    return LoginResult(_isLogged, errorType, errorMessage);
  }

  // Intentar fer login amb les credencials que hi ha emmagatzemades al sistema.
  //Es fa servir quan es vol carregar l'últim usuari que ha entrat a l'aplicació
  Future<LoginResult> loginWithStoredCredentials() async {
    final username = await _prefs.getLastLogin();
    if (username == null) {
      return LoginResult(DjauStatus.withoutUser, "", "");
    }
    final tutor = await _storage.loadTutor(username);
    if (tutor == null) {
      return LoginResult(DjauStatus.withoutUser, "", "");
    }
    // fer login
    return login(tutor.username, tutor.password);
  }

  /// Carrega l'alumne amb l'ID especificat.
  /// Es fa servir per carregar la variable `alumne` quan ja s'ha fet login i es vol
  /// carregar un altre alumne
  Future loadAlumne(int id) async {
    // Cridar a la llista d'alumnes associats
    var alumnes = await _repository.getAlumnesList();
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
    try {
    var username = await _prefs.getLastLogin();
    if (username == null) return 0;
    return 1;
    } catch (e) {
      return 0;
    }
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
    return response;
  }

  // Carregar el detalla de la sortida
  Future<Sortida> loadSortida(int id) async {
    final response = await _repository.getSortida(id);
    return response;
  }
}
