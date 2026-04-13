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
  /// Si tot va bé carrega la variable `alumne` i si no, posa l'estat en error
  Future<LoginResult> login(String username, String password) async {
    try {
      final response = await _repository.login(Login(username, password));
      tutor = await _storage.loadTutor(username);
      tutor.token = response.accessToken;
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

  /// Carrega la llista dels alumnes associats al tutor que ha entrat en el sistema. 
  /// Es fa servir per carregar la variable `alumne` quan ja s'ha fet login i es vol 
  /// carregar un altre alumne 
  Future<LoginResult> loadAlumne(int id) async {
    try {
      // Cridar a la llista d'alumnes associats
      var alumnes = await _repository.getAlumnesList();
      var alumneTrobat = alumnes.any((a) => a.id == id);
      if (!alumneTrobat) {
        // Redirigir a la pantalla d'alumnes associats
      }      
      alumne = alumnes.firstWhere((a) => a.id == id);  
      _prefs.setLastAlumne(alumne.id);    
      notifyListeners(); 
      return LoginResult(DjauStatus.loaded, "", "");
    } on AppException catch (f) {
      _isLogged = DjauStatus.withoutUser;
      errorType = f.prefix();
      errorMessage = f.message();
    } catch (e) {
      _isLogged = DjauStatus.withoutUser;
      errorMessage = "No hi ha dades de l'alumne ${alumne.nomComplet()}";
    }
    notifyListeners();
    return LoginResult(_isLogged, errorType, errorMessage);

  }


  /// Defineix quina és la pantalla inicial en iniciar el programa
  /// - No hi ha tutor -> Login (0)
  /// - Hi ha tutor (1) -> Carregar l'últim alumne 
  Future<int> determineInitialPage() async {
    var username = await _prefs.getLastLogin();
    if (username == null) return 0;
    return 1;
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
      _isLogged = DjauStatus.withoutUser;
      errorMessage = "L'alumne $alumne no pot es pot veure";
    }
  }


  /// Obtenir una llista amb els noms dels alumnes i el seu id.
  /// Cal per poder llistar els noms dels alumnes a més del seu
  /// id
  Future<Map<int, String>> getAlumnes() async {
    var resultat = <int, String>{};
    var alumnes = await _repository.getAlumnesList();
    for(var alumne in alumnes) {
      resultat[alumne.id] = alumne.nomComplet();
    }
    return resultat;
  }

  void logout() {
    notifyListeners();
  }

  /// Carrega el perfil de l'usuari que està actiu en aquest moment
  Future<Perfil> loadPerfil() async {
    final response = await _repository.getProfile();
    return response;
  }

  // Carregar el detalla de la sortida
  Future<Sortida> loadSortida(int id) async {
    final response = await _repository.getSortida(id);
    return response;
  }
}

