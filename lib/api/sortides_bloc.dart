import 'dart:async';

import 'package:cendrassos/api/api_response.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/resum_sortida.dart';
import 'package:flutter/material.dart';

class SortidesBlock {
  String _token = "";
  int _idAlumne = 0;

  NotificacionsRepository _notificacioRepository = NotificacionsRepository();
  StreamController<ApiResponse<List<ResumSortida>>>
      _resumSortidaListController =
      StreamController<ApiResponse<List<ResumSortida>>>();

  StreamSink<ApiResponse<List<ResumSortida>>> get resumSortidaListSink =>
      _resumSortidaListController.sink;

  Stream<ApiResponse<List<ResumSortida>>> get resumSortidaListStream =>
      _resumSortidaListController.stream;

  SortidesBlock(String token, int idAlumne) {
    _token = token;
    _idAlumne = idAlumne;
    _resumSortidaListController =
        StreamController<ApiResponse<List<ResumSortida>>>();
    _notificacioRepository = NotificacionsRepository();
    _notificacioRepository.setCurrentToken(_token);

    fetchSortides();
  }

  Future<void> fetchSortides() async {
    resumSortidaListSink.add(ApiResponse.loading(carregantSortides, []));
    try {
      _notificacioRepository.setCurrentToken(_token);
      var dades = await _notificacioRepository.getSortides(_idAlumne);
      resumSortidaListSink.add(ApiResponse.completed(dades));
    } catch (e) {
      resumSortidaListSink.add(ApiResponse.error(e.toString(), []));
      debugPrint(e.toString());
    }
  }

  void dispose() {
    _resumSortidaListController.close();
  }

  String getToken() {
    return _token;
  }

  void setToken(String token) {
    _token = token;
    _notificacioRepository.setCurrentToken(_token);
  }
}
