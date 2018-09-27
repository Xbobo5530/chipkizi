import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recording_body.dart';
import 'package:flutter/material.dart';

class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(APP_NAME),
      ),
      body: new RecordingBody(),
    );
  }
}
