import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config_djau.dart';

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';
/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';
/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';
/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

class NotificationManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AndroidInitializationSettings? initializationSettingsAndroid;
  DarwinInitializationSettings? initializationSettingsDarwin;
  LinuxInitializationSettings? initializationSettingsLinux;
  InitializationSettings? initializationSettings;

  String? selectedNotificationPayload;

  static const channelId = "123";

  NotificationManager() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future initNotificationManager(Function(String? p) selectNotification) async {
    initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          darwinNotificationCategoryText,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.text(
              'text_1',
              'Action 1',
              buttonTitle: 'Send',
              placeholder: 'Placeholder',
            ),
          ],
        ),
        DarwinNotificationCategory(
          darwinNotificationCategoryPlain,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(urlLaunchActionId, 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2 (destructive)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              navigationActionId,
              'Action 3 (foreground)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'id_4',
              'Action 4 (auth required)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.authenticationRequired,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
      ];

    final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: darwinNotificationCategories,
      );
    
    initializationSettingsLinux = const LinuxInitializationSettings(
        defaultActionName: 'Open notification');

    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin
        .initialize(settings:initializationSettings!); //,
           //onDidReceiveNotificationResponse: onDidReceiveNotificationResponse); <-- TODO: On vaig quan hi cliquen (basat en selectedNotification)
            //settings: initializationSettings,
            //onDidReceiveNotificationResponse: selectNotificationStream.add,
            // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  
  }

  // void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  //     final String? payload = notificationResponse.payload;
  //     if (notificationResponse.payload != null) {
  //       debugPrint('notification payload: $payload');
  //     }
  //     await Navigator.push(
  //       context,
  //       MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  //     );
  // }

  Future<void> showNotification(int idAlumne, String nom) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      channelId,
      appName,
      channelDescription: 'Notificacions del Djau',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id: idAlumne,
      title: nomInstitut,
      body: 'Notificacions al Djau de $nom',
      notificationDetails: platformChannelSpecifics,
      payload: idAlumne.toString(),
    );
  }
}
