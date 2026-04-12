import 'package:cendrassos/models/tutor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future writeSecureStorage(String key, String value) async {
    var writeData = await _storage.write(key: key, value: value);
    return writeData;
  }

  Future readSecureData(String key) async {
    var readData = await _storage.read(key: key);
    return readData;
  }

  Future deleteSecureData(String key) async {
    var deleteData = await _storage.delete(key: key);
    return deleteData;
  }
}

class DjauSecureStorage {
  final SecureStorage _storage = SecureStorage();

  /// Emmagatzema les credencials del tutor en el Secure Storage del sistema
  /// en el que estigui corrent l'aplicació.
  Future<void> saveTutor(Tutor tutor) async {
    var json = jsonEncode(tutor.toJson());
    _storage.writeSecureStorage(tutor.username, json);
  }

  Future<dynamic> loadCurrentTutor() async {
    var username = await DjauLocalStorage().getLastLogin();
    if (username != null) {
      return loadTutor(username);
    } else {
      throw Exception("Not found");
    }
  }

  Future<dynamic> loadTutor(String username) async {
    var data = await _storage.readSecureData(username);
    if (data != null) {
      var responseJson = json.decode(data);
      return Tutor.fromJson(responseJson);
    } else {
      throw Exception("Not found");
    }
  }

}

class DjauLocalStorage {
  static const String lastLoginKey = 'lastlogin'; // Ultim usuari loginat
  static const String lastAlumneKey = 'lastalumne'; // Darrer alumne seleccionat
  static const String alumnesKey = 'alumnes'; // llista d'alumnes confirmats

  /// Obtenir el darrer username que ha entrat en l'aplicació o null
  /// si no ha entrat mai ningú
  Future<String?> getLastLogin() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastLoginKey);
  }

  /// Emmagatzema quin ha estat l'username que ha entrat en l'aplicació
  /// que està definit a [username]
  Future<void> setLastLogin(String username) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(lastLoginKey, username);
  }

  Future<void> setLastAlumne(int id) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(lastAlumneKey, id);
  }

  Future<int?> getLastAlumne() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastAlumneKey);
  }





}
