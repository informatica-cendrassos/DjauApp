import 'dart:async';
import 'package:cendrassos/api/login_response.dart';
import 'package:cendrassos/api/news_query.dart';
import 'package:cendrassos/api/news_response.dart';
import 'package:cendrassos/api/notificacions_response.dart';
import 'package:cendrassos/api/resum_sortides_response.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/perfil.dart';
import 'package:cendrassos/models/resum_sortida.dart';
import 'package:cendrassos/models/sortida.dart';
import 'package:flutter/material.dart';

import '../models/alumne.dart';
import '../models/login.dart';
import 'api_base_helper.dart';
import '../models/notificacio.dart';

class NotificacionsRepository {
  late final ApiBaseHelper _helper;

  NotificacionsRepository() {
    _helper = ApiBaseHelper(refreshTokenMethod);
  }

  static String bearerText = "Bearer";

  Map<String, String> getHeaders(String token) => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "$bearerText $token",
      };

  static Login? lastLogin;
  static String currentToken = "";


  // Crida al login per obtenir el token, que després es pot usar per a les altres crides
  // ------------------------------------------------------
  Future<LoginResponse> login(Login dades) async {
    var url = pathLogin;
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await _helper.post(url, dades.toJson(), requestHeaders);
    lastLogin = dades;
    currentToken = response["access"];

    return LoginResponse.fromJson(response);
  }

  // Refresh del token, que es fa quan el client rep un 401, i que després es pot usar per a les altres crides
  // ------------------------------------------------------
  Future<LoginResponse> refreshTokenMethod() async {
    debugPrint('Relogin');

    var response = await login(lastLogin!);
    currentToken = response.accessToken;
    return response;
  }

  // Obtenir els alumnes associats a un tutor concret
  // ------------------------------------------------------
  Future<List<Alumne>> getAlumnesList() async {
    var url = pathAlumnes;

    final response = await _helper.get(url, getHeaders(currentToken));
    return (response as List).map((e) => Alumne.fromJson(e)).toList();
  }

  // Obtenir les notificacions d'un mes concret
  // ------------------------------------------------------
  Future<List<Notificacio>> getNotifications(int mes, int idAlumne) async {
    var url = "$pathNotificacions/$mes/$idAlumne";

    final response = await _helper.get(url, getHeaders(currentToken));

    var results = NotificacionsResponse.fromApi(response);
    return results.results;
  }

  // Comprovar si hi ha notificacions noves des de l'última sincronització
  // ------------------------------------------------------
  Future<bool> areNewNotifications(String token, Alumne alumne, String lastSyncDate) async {
    var url = "$pathNews/${alumne.id}";
    try {      
      var query = NewsQuery(lastSyncDate: lastSyncDate).toJson();
      final response =
          await _helper.post(url, query, getHeaders(token));
      debugPrint("Result $response");
      return NewsResponse.fromJson(response).resultIs("Sí");
    } catch (e) {
      return false;
    }
  }

  Future<Perfil> getProfile(int idAlumne) async {
    var url = "$pathProfile/$idAlumne";

    final response = await _helper.get(url, getHeaders(currentToken));
    return Perfil.fromJson(response);
  }

// Sortides

  Future<List<ResumSortida>> getSortides(int idAlumne) async {
    var url = "$pathSortides/$idAlumne";

    final response = await _helper.get(url, getHeaders(currentToken));

    var results = ResumSortidesResponse.fromApi(response);
    return results.results;
  }

  Future<Sortida> getSortida(int id) async {
    var url = "$pathSortides/$id/";

    final response = await _helper.get(url, getHeaders(currentToken));
    return Sortida.fromJson(response);
  }
}
