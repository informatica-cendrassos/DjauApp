import 'package:background_fetch/background_fetch.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/services/notifications_manager.dart';
import 'package:cendrassos/services/storage.dart';
import 'package:flutter/material.dart';

Future<void> runBackgroundFetch(
  String taskId,
  Future<void> Function() task,
) async {
  try {
    await task();
    debugPrint('[BackgroundFetch] Task completed.');
  } catch (error, stackTrace) {
    debugPrint('[BackgroundFetch] Task failed (${error.runtimeType}).');
    debugPrintStack(stackTrace: stackTrace);
  } finally {
    try {
      await BackgroundFetch.finish(taskId);
    } catch (error, stackTrace) {
      debugPrint('[BackgroundFetch] Failed to finish (${error.runtimeType}).');
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

class BackgroundTask {
  BackgroundTask({DjauSecureStorage? storage})
      : storage = storage ?? DjauSecureStorage();

  NotificationManager manager = NotificationManager();
  NotificacionsRepository api = NotificacionsRepository();
  DjauLocalStorage prefs = DjauLocalStorage();
  DjauSecureStorage storage;

  Future<void> checkNewNotificacions(dynamic Function(String? p) goto) async {
    debugPrint('[BackgroundFetch] Loading session.');
    final Tutor? tutor = await storage.loadCurrentTutor();
    if (tutor == null || tutor.username.isEmpty) {
      debugPrint('[BackgroundFetch] No stored session.');
      return;
    }

    debugPrint('[BackgroundFetch] Initializing notifications.');
    await manager.initNotificationManager(goto);
    api.setTutorSession(tutor);
    debugPrint('[BackgroundFetch] Loading pupils.');
    // Per cada alumne associat al tutor, comprovar si hi ha notificacions noves, i si n'hi ha, mostrar una notificació
    var alumnes = await api.getAlumnesList(); // No sé si fer-ho o no
    debugPrint('[BackgroundFetch] Checking for new notifications.');
    for (var i = 0; i < alumnes.length; i++) {
      if (await api.areNewNotifications(api.currentToken, alumnes[i])) {
        debugPrint('[BackgroundFetch] Displaying a notification.');
        await manager.showNotification(alumnes[i].id, alumnes[i].nomComplet());
      }
    }
    final updatedTutor = Tutor.fromNow(
      tutor.username,
      tutor.password,
      api.currentToken,
      api.refreshToken,
    );
    await storage.saveTutor(updatedTutor);
  }
}
