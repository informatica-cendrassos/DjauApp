import 'dart:async';

import 'package:cendrassos/api/api_response.dart';
import 'package:cendrassos/models/notificacio.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:flutter/material.dart';

class NotificacioBloc {
  Tutor _tutor = Tutor('', '', '', '');
  int _id = 0;
  NotificacionsRepository _notificacioRepository = NotificacionsRepository();
  StreamController<ApiResponse<List<Notificacio>>> _notificacioListController =
      StreamController<ApiResponse<List<Notificacio>>>();

  StreamSink<ApiResponse<List<Notificacio>>> get notificationsListSink =>
      _notificacioListController.sink;

  Stream<ApiResponse<List<Notificacio>>> get notificationsListStream =>
      _notificacioListController.stream;

  NotificacioBloc(Tutor tutor, int id) {
    _notificacioListController =
        StreamController<ApiResponse<List<Notificacio>>>();
    _notificacioRepository = NotificacionsRepository();
    _tutor = tutor;
    _notificacioRepository.setTutorSession(_tutor);
    _id = id;
    fetchNotificacions(DateTime.now().month);
  }

  Future<void> fetchNotificacions(int mes) async {
    notificationsListSink
        .add(ApiResponse.loading('Recuperant notificacions', []));
    try {
      var dades = await _notificacioRepository.getNotifications(mes, _id);
      _notificacioRepository.syncTutorSession(_tutor);
      notificationsListSink.add(ApiResponse.completed(dades));
    } catch (e) {
      notificationsListSink.add(ApiResponse.error(e.toString(), []));
      debugPrint(e.toString());
    }
  }

  void dispose() {
    _notificacioListController.close();
  }

  String getToken() {
    return _tutor.token;
  }

  void setTutor(Tutor tutor) {
    _tutor = tutor;
    _notificacioRepository.setTutorSession(_tutor);
  }
}
