import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/pages/home.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

final MainModel model = MainModel();
void main() => runApp(MyApp(model: model));

class MyApp extends StatelessWidget {
  final MainModel model;
  MyApp({this.model});
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
//        home: HomePage(),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
        },
      ),
    );
  }
}
