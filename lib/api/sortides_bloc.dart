import 'dart:async';

import 'package:cendrassos/api/api_response.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/resum_sortida.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:flutter/material.dart';

class SortidesBlock {
  Tutor _tutor = Tutor('', '', '', '');
  int _idAlumne = 0;

  NotificacionsRepository _notificacioRepository = NotificacionsRepository();
  StreamController<ApiResponse<List<ResumSortida>>>
      _resumSortidaListController =
      StreamController<ApiResponse<List<ResumSortida>>>();

  StreamSink<ApiResponse<List<ResumSortida>>> get resumSortidaListSink =>
      _resumSortidaListController.sink;

  Stream<ApiResponse<List<ResumSortida>>> get resumSortidaListStream =>
      _resumSortidaListController.stream;

  SortidesBlock(Tutor tutor, int idAlumne) {
    _tutor = tutor;
    _idAlumne = idAlumne;
    _resumSortidaListController =
        StreamController<ApiResponse<List<ResumSortida>>>();
    _notificacioRepository = NotificacionsRepository();
    _notificacioRepository.setTutorSession(_tutor);

    fetchSortides();
  }

  Future<void> fetchSortides() async {
    resumSortidaListSink.add(ApiResponse.loading(carregantSortides, []));
    try {
      var dades = await _notificacioRepository.getSortides(_idAlumne);
      _notificacioRepository.syncTutorSession(_tutor);
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
    return _tutor.token;
  }

  void setTutor(Tutor tutor) {
    _tutor = tutor;
    _notificacioRepository.setTutorSession(_tutor);
  }
}
