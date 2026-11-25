import 'package:background_fetch/background_fetch.dart';
import 'package:cendrassos/api/notificacions_repository.dart';
import 'package:cendrassos/api/exceptions.dart';
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

  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  NotificationManager manager = NotificationManager();
  NotificacionsRepository api = NotificacionsRepository();
  DjauLocalStorage prefs = DjauLocalStorage();
  DjauSecureStorage storage;

  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation, {
    int retryCount = 0,
  }) async {
    try {
      return await operation();
    } on FetchDataException catch (error) {
      if (!error.retryable) {
        debugPrint('[BackgroundFetch] Request not retried: outcome uncertain.');
        rethrow;
      }
      if (retryCount < _maxRetries) {
        debugPrint(
          '[BackgroundFetch] Retry ${retryCount + 1}/$_maxRetries after network error',
        );
        await Future.delayed(_retryDelay);
        return _retryWithBackoff(operation, retryCount: retryCount + 1);
      }
      debugPrint('[BackgroundFetch] Max retries reached.');
      rethrow;
    }
  }

  Future<T> _withTutorSync<T>(
    Tutor tutor,
    Future<T> Function() operation,
  ) async {
    var operationFailed = false;
    try {
      return await operation();
    } catch (error) {
      operationFailed = true;
      if (error is FetchDataException) {
        debugPrint(
          '[BackgroundFetch] Communication error during operation.',
        );
      }
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
    final alumnes = await _retryWithBackoff(
      () => _withTutorSync(tutor, api.getAlumnesList),
    );
    debugPrint('[BackgroundFetch] Checking for new notifications.');
    for (final alumne in alumnes) {
      try {
        final hasNews = await _retryWithBackoff(
          () => _withTutorSync(
            tutor,
            () => api.areNewNotifications(api.currentToken, alumne),
          ),
        );
        debugPrint(
            '[BackgroundFetch] New notifications: ${hasNews ? 'yes' : 'no'}.');
        if (hasNews) {
          debugPrint('[BackgroundFetch] Displaying a notification.');
          await manager.showNotification(alumne.id, alumne.nomComplet());
        }
      } catch (error) {
        debugPrint(
          '[BackgroundFetch] Failed to check notifications for '
          '${alumne.nomComplet()} (${error.runtimeType}).',
        );
      }
    }
  }
}
