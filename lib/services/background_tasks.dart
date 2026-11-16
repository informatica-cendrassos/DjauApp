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

  Future<T> _withTutorSync<T>(
    Tutor tutor,
    Future<T> Function() operation,
  ) async {
    var operationFailed = false;
    try {
      return await operation();
    } catch (_) {
      operationFailed = true;
      rethrow;
    } finally {
      if (tutor.token != api.currentToken ||
          tutor.refreshToken != api.refreshToken) {
        try {
          final updatedTutor = Tutor.fromNow(
            tutor.username,
            tutor.password,
            api.currentToken,
            api.refreshToken,
          );
          await storage.saveTutor(updatedTutor);
          api.syncTutorSession(tutor);
        } catch (error, stackTrace) {
          if (!operationFailed) rethrow;
          debugPrint(
            '[BackgroundFetch] Failed to save refreshed session '
            '(${error.runtimeType}).',
          );
          debugPrintStack(stackTrace: stackTrace);
        }
      }
    }
  }

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
    final alumnes = await _withTutorSync(tutor, api.getAlumnesList);
    debugPrint('[BackgroundFetch] Checking for new notifications.');
    for (final alumne in alumnes) {
      final hasNews = await _withTutorSync(
        tutor,
        () => api.areNewNotifications(api.currentToken, alumne),
      );
      debugPrint(
          '[BackgroundFetch] New notifications: ${hasNews ? 'yes' : 'no'}.');
      if (hasNews) {
        debugPrint('[BackgroundFetch] Displaying a notification.');
        await manager.showNotification(alumne.id, alumne.nomComplet());
      }
    }
  }
}
