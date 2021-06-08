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
  final scheduler = NeatPeriodicTaskScheduler(
    interval: Duration(hours: 1),
    name: 'Vaccine Check',
    timeout: Duration(seconds: 5),
    task: () async {
      // DateTime datenow = DateTime.now();
      // while (datenow.hour > 18 && datenow.hour < 23) {
      //some say they add data 6pm - 11pm }
      await fetchvcn(http.Client(), {
        'date': DateTime.now().day.toString() +
            '-' +
            DateTime.now().month.toString() +
            '-' +
            DateTime.now().year.toString(),
        'pincode': '400092', //pin to be replaced from local storage
      });

      if (stat) await _showNotification();
    },
    minCycle: Duration(minutes: 5),
  );

  scheduler.start();
  await ProcessSignal.sigterm.watch().first;
  await scheduler.stop();
}

Future<void> _showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('1', 'vaccine', 'vaccine alert',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'Vaccine Alert', 'Vaccine Found @ 400092', platformChannelSpecifics,
      payload: 'Vaccine Check');
}

fetchvcn(http.Client client, args) async {
  dynamic urlz =
      'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?date=' +
          args["date"] +
          '&pincode=' +
          args["pincode"].toString();

  final response = await client.get(Uri.parse(urlz));

  final parsed = jsonDecode(response.body);

  var dataz = parsed['sessions'] as List;

  dynamic vaccinedata =
      dataz.firstWhere((element) => element['available_capacity'] > 0);

  if (vaccinedata != null && vaccinedata['available_capacity'] > 0) stat = true;

  return stat;
}
