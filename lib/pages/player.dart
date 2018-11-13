import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:simple_coverflow/simple_coverflow.dart';

class PlayerPage extends StatelessWidget {
  final Recording recording;

  const PlayerPage({Key key, this.recording}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _recordingSection = Container();

    final _controlsSection = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[],
    );

    final _appBar = AppBar(
      title: Hero(
        tag: TAG_APP_TITLE,
        child: Text(APP_NAME),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: _appBar,
      body: Column(
        children: <Widget>[
          _recordingSection,
          _controlsSection,
        ],
      ),
    );
  }
}
