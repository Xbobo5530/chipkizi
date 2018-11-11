import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recording_body.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingPage extends StatelessWidget {
  final _bodySection =
      ScopedModelDescendant<MainModel>(builder: (_, __, model) {
    return Column(children: <Widget>[
      model.isRecording ? Text(model.recorderTxt) : Text(model.playerText),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: model.isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
            onPressed: model.isRecording
                ? () => model.stopRecording()
                : () => model.startRecording(),
          ),
        ],
      ),
      model.isRecording
          ? Container()
          : Container(
              child: model.isPlaying
                  ? ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: model.isPaused
                              ? Icon(Icons.play_arrow)
                              : Icon(Icons.pause),
                          onPressed: model.isPaused
                              ? () => model.resumePlayback()
                              : () => model.pausePlayback(),
                        ),
                        IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: () => model.stopPlayback(),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () => model.playPlayback(),
                    ))
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
