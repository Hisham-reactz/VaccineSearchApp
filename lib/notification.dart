import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

bool stat = false;

String selectedNotificationPayload;

Future<void> initz() async {
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
}

Future<void> check() async {
// Create a periodic task that prints 'Hello World' every 30s
  final scheduler = NeatPeriodicTaskScheduler(
    interval: Duration(days: 1),
    name: 'Vaccine Check',
    timeout: Duration(seconds: 15),
    task: () async {
      if (fetchvcn(http.Client(), {
        'date': DateTime.now().day.toString() +
            '-' +
            DateTime.now().month.toString() +
            '-' +
            DateTime.now().year.toString(),
        'pincode': '679322',
      })) _showNotification();
    }, //pin to be replaced from local storage
    minCycle: Duration(minutes: 5),
  );

  scheduler.start();
  await ProcessSignal.sigterm.watch().first;
  await scheduler.stop();
}

Future<void> requestPermissions() async {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

Future<void> _showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'plain title', 'plain body', platformChannelSpecifics,
      payload: 'item x');
}

fetchvcn(http.Client client, args) async {
  dynamic urlz =
      'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?date=' +
          args["date"] +
          '&pincode=' +
          args["pincode"].toString();

  final response = await client.get(Uri.parse(urlz));

  final parsed = jsonDecode(response.body);
  parsed != null && parsed["sessions"] ??
      parsed["sessions"].map((json) => {
            if (num.parse(json['available_capacity_dose1']).toInt() > 0)
              {stat = true}
          });

// Use the compute function to run parsePhotos in a separate isolate.
  return stat;
}
