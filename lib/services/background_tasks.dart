import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/services/notifications_manager.dart';
import 'package:cendrassos/services/storage.dart';
import 'package:flutter/material.dart';

class BackgroundTask {
  NotificationManager manager = NotificationManager();
  NotificacionsRepository api = NotificacionsRepository();
  DjauLocalStorage prefs = DjauLocalStorage();
  DjauSecureStorage storage = DjauSecureStorage();

  Future<void> checkNewNotificacions(dynamic Function(String? p) goto) async {
    await manager.initNotificationManager(goto);
    var tutor = await storage.loadCurrentTutor();
    if (tutor.username.isEmpty) {
      return;
    }

    api.setTutorSession(tutor);
    // Per cada alumne associat al tutor, comprovar si hi ha notificacions noves, i si n'hi ha, mostrar una notificació
    var alumnes = await api.getAlumnesList(); // No sé si fer-ho o no
    for (var i = 0; i < alumnes.length; i++) {
      if (await api.areNewNotifications(api.currentToken, alumnes[i])) {
        debugPrint('[BackgroundFetch] $alumnes[i] Si');
        await manager.showNotification(alumnes[i].id, alumnes[i].nomComplet());
      }
    }
    tutor = Tutor.fromNow(
      tutor.username,
      tutor.password,
      api.currentToken,
      api.refreshToken,
    );
    await storage.saveTutor(tutor);
  }
}
