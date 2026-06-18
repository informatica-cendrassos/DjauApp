import 'dart:async';
import 'package:cendrassos/api/login_response.dart';
import 'package:cendrassos/api/news_response.dart';
import 'package:cendrassos/api/notificacions_response.dart';
import 'package:cendrassos/api/resum_sortides_response.dart';
import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/models/perfil.dart';
import 'package:cendrassos/models/resum_sortida.dart';
import 'package:cendrassos/models/sortida.dart';
import 'package:flutter/foundation.dart';

import '../models/alumne.dart';
import '../models/login.dart';
import 'api_base_helper.dart';
import '../models/notificacio.dart';

class NotificacionsRepository {
  static const bool _debugLogsEnabled = kDebugMode;

  late final ApiBaseHelper _helper;
  Login? _lastLogin;
  String _currentToken = "";
  String _refreshToken = "";
  bool _isRefreshing = false;

  NotificacionsRepository() {
    _helper = ApiBaseHelper(refreshTokenMethod);
  }

  static String bearerText = "Bearer";

  void _logDebug(String message) {
    if (_debugLogsEnabled) {
      debugPrint(message);
    }
  }

  void setCurrentToken(String token) {
    _currentToken = token;
  }

  String get currentToken => _currentToken;

  String get refreshToken => _refreshToken;

  void setTutorSession(Tutor tutor) {
    _currentToken = tutor.token;
    _refreshToken = tutor.refreshToken;
    if (tutor.username.isNotEmpty && tutor.password.isNotEmpty) {
      _lastLogin = Login(tutor.username, tutor.password);
    }
  }

  void syncTutorSession(Tutor tutor) {
    tutor.token = _currentToken;
    tutor.refreshToken = _refreshToken;
  }

  Map<String, String> getHeaders(String token) => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "$bearerText $token",
      };

  // Crida al login per obtenir el token, que després es pot usar per a les altres crides
  // ------------------------------------------------------
  Future<LoginResponse> login(Login dades) async {
    var url = pathLogin;
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await _helper.post(url, dades.toJson(), requestHeaders);
    _lastLogin = dades;
    final loginResponse = LoginResponse.fromJson(response);
    _currentToken = loginResponse.accessToken;
    if (loginResponse.refreshToken.isNotEmpty) {
      _refreshToken = loginResponse.refreshToken;
    }

    return loginResponse;
  }

  // Refresh del token, que es fa quan el client rep un 401, i que després es pot usar per a les altres crides
  // ------------------------------------------------------
  Future<LoginResponse> refreshTokenMethod() async {
    _logDebug('Relogin');

    if (_isRefreshing) {
      throw UnauthorisedException(errorFentLogin);
    }

    _isRefreshing = true;
    try {
      if (_refreshToken.isNotEmpty) {
        try {
          final response = await _helper.post(
            tokenRefresh,
            {LoginResponse.refreshField: _refreshToken},
            {
              'Content-type': 'application/json',
              'Accept': 'application/json',
            },
          );
          final loginResponse = LoginResponse.fromJson(response);
          _currentToken = loginResponse.accessToken;
          if (loginResponse.refreshToken.isNotEmpty) {
            _refreshToken = loginResponse.refreshToken;
          }
          return LoginResponse(
            accessToken: _currentToken,
            refreshToken: _refreshToken,
          );
        } on UnauthorisedException catch (error) {
          _logDebug(
            'Refresh token rejected. Trying login fallback. ${error.message()}',
          );
        } on BadRequestException catch (error) {
          _logDebug(
            'Refresh token bad request. Trying login fallback. ${error.message()}',
          );
        }
      }

      if (_lastLogin == null) {
        throw UnauthorisedException(errorFentLogin);
      }

      final response = await login(_lastLogin!);
      _currentToken = response.accessToken;
      if (response.refreshToken.isNotEmpty) {
        _refreshToken = response.refreshToken;
      }
      return response;
    } finally {
      _isRefreshing = false;
    }
  }

  // Obtenir els alumnes associats a un tutor concret
  // ------------------------------------------------------
  Future<List<Alumne>> getAlumnesList() async {
    var url = pathAlumnes;

    final response = await _helper.get(url, getHeaders(_currentToken));
    return (response as List).map((e) => Alumne.fromJson(e)).toList();
  }

  // Obtenir les notificacions d'un mes concret
  // ------------------------------------------------------
  Future<List<Notificacio>> getNotifications(int mes, int idAlumne) async {
    var url = "$pathNotificacions/$mes/$idAlumne";

    final response = await _helper.get(url, getHeaders(_currentToken));

    var results = NotificacionsResponse.fromApi(response);
    return results.results;
  }

  // Comprovar si hi ha notificacions noves des de l'última sincronització
  // ------------------------------------------------------
  Future<bool> areNewNotifications(String token, Alumne alumne) async {
    var url = "$pathNews/${alumne.id}";
    try {
      final response = await _helper.get(url, getHeaders(token));
      _logDebug("Result $response");
      return NewsResponse.fromJson(response).resultIs("Sí");
    } catch (e) {
      return false;
    }
  }

  Future<Perfil> getProfile(int idAlumne) async {
    var url = "$pathProfile/$idAlumne";

    final response = await _helper.get(url, getHeaders(_currentToken));
    return Perfil.fromJson(response);
  }

// Sortides

  Future<List<ResumSortida>> getSortides(int idAlumne) async {
    var url = "$pathSortides/$idAlumne";

    final response = await _helper.get(url, getHeaders(_currentToken));

    var results = ResumSortidesResponse.fromApi(response);
    return results.results;
  }

  Future<Sortida> getSortida(int id, int alumneId) async {
    var url = "$pathSortides/$id/$alumneId";

    final response = await _helper.get(url, getHeaders(_currentToken));
    return Sortida.fromJson(response);
  }
}
