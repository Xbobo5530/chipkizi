import 'package:chipkizi/pages/create_recording.dart';
import 'package:chipkizi/views/home_body.dart';
import 'package:chipkizi/views/recording_body.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  //todo check if user is logged in

  @override
  Widget build(BuildContext context) {
    var url =
        'http://4.bp.blogspot.com/-5bOnQFyOklY/T3hD_G4ZkqI/AAAAAAAAAPU/KqPpuVGs2O0/s320/Cleveland%2BMitchell.jpg';
    return new Scaffold(
      appBar: new AppBar(
        leading: Icon(Icons.mic_none),
        title: new Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(url),
            ),
          )
        ],
      ),
      body: new HomeBodyView(),
    );
  }
}
