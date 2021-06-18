import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

bool stat = false;
int pincode;
int iz = 0;
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

getLocalPin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('pincode')) pincode = prefs.getInt('pincode');
}

clearLocalPin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('pincode')) prefs.remove('pincode');
}

setLocalPin(pin) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('pincode', pin);
}

Future<void> check() async {
  final scheduler = NeatPeriodicTaskScheduler(
    interval: Duration(minutes: 15),
    name: 'Vaccine Check',
    timeout: Duration(seconds: 5),
    task: () async {
      DateTime datenow = DateTime.now();
// while (datenow.hour > 18 && datenow.hour < 23) {
//some say they add data 6pm - 11pm }
      pincode = null;
      await getLocalPin();
      print(pincode);
      stat = false;
      await fetchvcn(http.Client(), {
        'date': datenow.day.toString() +
            '-' +
            datenow.month.toString() +
            '-' +
            datenow.year.toString(),
        'pincode': pincode.toString() != 'null'
            ? pincode.toString()
            : '', //will get from loc data once g map module done;
      });
      print(stat);
      if (stat) {
        iz++;
        AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
                iz.toString(), 'vaccine', 'vaccine alert',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker ' + iz.toString());
        NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
            iz,
            'Vaccine Alert ' + iz.toString(),
            'Vaccine Found @ ' + pincode.toString() != 'null'
                ? pincode.toString()
                : '',
            platformChannelSpecifics,
            payload: 'Vaccine Check ' + iz.toString());
      }
    },
    minCycle: Duration(minutes: 5),
  );

  scheduler.start();
  await ProcessSignal.sigterm.watch().first;
  await scheduler.stop();
}

fetchvcn(http.Client client, args) async {
  dynamic urlz =
      'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?date=' +
          args["date"] +
          '&pincode=' +
          args["pincode"].toString();

  final response = await client.get(Uri.parse(urlz));

  final parsed = jsonDecode(response.body);

  var dataz = parsed['centers'] as List;

  for (var center in dataz) {
    for (var session in center['sessions']) {
      if (session['available_capacity'] > 0) {
        stat = true;
        return stat;
      }
    }
  }

  return stat;
}
