import 'dart:io';
import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/error.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:http/retry.dart';

class ApiBaseHelper {
  static const bool _debugLogsEnabled = kDebugMode;

  static Uri createUrl(String urlpath) {
    return Uri.parse("$baseUrl$urlpath$endBaseUrl");
  }

  static void _logDebug(String message) {
    if (_debugLogsEnabled) {
      debugPrint(message);
    }
  }

  static String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  static bool isAuthEndpointPath(String requestPath) {
    final normalizedRequestPath = _normalizePath(requestPath);
    return normalizedRequestPath == _normalizePath(pathLogin) ||
        normalizedRequestPath == _normalizePath(tokenRefresh);
  }

  late RetryClient client;
  late String newToken;

  ApiBaseHelper(Function relogin) {
    client = RetryClient(http.Client(),
        when: (response) => response.statusCode == 401,
        onRetry: (request, response, retryCount) async {
          if (retryCount == 0 && response?.statusCode == 401) {
            final requestPath = request.url.path;
            final isAuthEndpoint = isAuthEndpointPath(requestPath);
            if (isAuthEndpoint) {
              return;
            }

            var result = await relogin();
            if (result is Map && result.containsKey('access')) {
              newToken = result['access'] as String;
            } else {
              newToken = result.accessToken as String;
            }

            if (newToken.isNotEmpty) {
              request.headers['Authorization'] = '$bearerText $newToken';
            }
          }
        });
  }

  static String bearerText = "Bearer";

  Map<String, String> getHeaders(String token) => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "$bearerText $token",
      };

  static const String noInternet =
      "Hi ha problemes per accedir a la xarxa. Proveu-ho més tard";

  // Future<dynamic> get(String url) async {
  //   print('Api Get, url $url');
  //   var responseJson;
  //   try {
  //     final response = await http.get(Uri.parse(_baseUrl + url));
  //     responseJson = _returnResponse(response);
  //   } on SocketException {
  //     print('No net');
  //     throw FetchDataException(NOINTERNET);
  //   }
  //   return responseJson;
  // }

  Future<dynamic> get(String path, [dynamic headers]) async {
    _logDebug('Api Get, url $path');
    headers ??= {};
    dynamic responseJson;
    try {
      var url = createUrl(path);
      final response = await client.get(url, headers: headers);
      responseJson = _returnResponse(response);
    } on SocketException {
      _logDebug('No net');
      throw FetchDataException(noInternet);
    } on NoSuchMethodError catch (e) {
      _logDebug(e.toString());
      throw FetchDataException("El servidor rebutja la petició");
    }
    return responseJson;
  }

  Future<dynamic> post(String path, dynamic body, [dynamic headers]) async {
    _logDebug('Api Post, url $path');
    headers ??= {};

    try {
      var url = createUrl(path);
      final response =
          await client.post(url, body: jsonEncode(body), headers: headers);
      var responseJson = _returnResponse(response);
      return responseJson;
    } on SocketException {
      _logDebug('No net');
      throw FetchDataException(noInternet);
    } on NoSuchMethodError catch (e) {
      _logDebug(e.toString());
      throw FetchDataException("El servidor rebutja la petició");
    }
  }
}

dynamic _returnResponse(http.Response response) {
  if (response.statusCode == 200) {
    var responseJson = json.decode(utf8.decode(response.bodyBytes));
    return responseJson;
  } else {
    try {
      var jsonresult = json.decode(utf8.decode(response.bodyBytes));
      DjauError result = DjauError.fromJson(jsonresult);
      switch (response.statusCode) {
        case 400:
          throw BadRequestException(result.toString());
        case 401:
        case 403:
        case 405:
          throw UnauthorisedException(result.toString());
        case 404:
          throw FetchDataException(
              'Error. Es demana un lloc inexistent. ${response.statusCode}:${response.reasonPhrase}');
        case 500:
        default:
          throw FetchDataException(
              'Error en connectar amb el servidor. ${response.statusCode}:$result. Proveu-ho més tard');
      }
    } on FormatException catch (_) {
      throw FetchDataException(
          'Sembla que el servidor té problemes. ${response.statusCode}: Proveu-ho més tard');
    }
  }
}
