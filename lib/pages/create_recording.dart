import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recording_body.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildPlayerControls(MainModel model) => Container(
            child: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => model.playPlayback(),
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () => model.pausePlayback(),
            ),
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: () => model.stopPlayback(),
            ),
          ],
        ));

    _handleRecording(BuildContext context, MainModel model) {
      model.isRecording ? model.stopRecording() : model.startRecording();

      if (!model.isRecording)
        Scaffold.of(context).showBottomSheet((context) {
          return _buildPlayerControls(model);
        });
    }

    final _bodySection =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return Column(children: <Widget>[
        model.isRecording ? Text(model.recorderTxt) : Text(model.playerText),
        Center(
          child: Builder(
            builder: (context) {
              return IconButton(
                icon: model.isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
                onPressed: () => _handleRecording(context, model),
              );
            },
          ),
        ),
      ]);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(APP_NAME),
      ),
      body: _bodySection /*RecordingBody()*/,
    );
  }
}
