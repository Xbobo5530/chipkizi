import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recording_body.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingPage extends StatelessWidget {
  final _bodySection =
      ScopedModelDescendant<MainModel>(builder: (_, __, model) {
    return Column(children: <Widget>[
      Text(model.playerText),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: () => model.startRecording(),
          ),
        ],
      ),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {},
          ),
        ],
      )
    ]);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(APP_NAME),
      ),
      body: _bodySection /*RecordingBody()*/,
    );
  }
}
