import 'package:chipkizi/pages/home.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: APP_NAME,
      theme: new ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: new HomePage(title: APP_NAME),
    );
  }
}
