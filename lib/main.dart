import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/pages/home.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

final MainModel _model = MainModel();
void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MyApp(model: _model)));
}

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
