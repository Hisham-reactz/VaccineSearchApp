import 'package:flutter/material.dart';
import 'register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
