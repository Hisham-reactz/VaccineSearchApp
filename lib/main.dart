import 'package:flutter/material.dart';
import 'register.dart';
import 'notification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initz();
  check();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaccinator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegisterPageWidget(),
    );
  }
}
