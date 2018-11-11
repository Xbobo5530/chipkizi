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
      switch (model.isRecording) {
        case true:
          model.stopRecording();
          Scaffold.of(context).showBottomSheet((context) {
            return _buildPlayerControls(model);
          });
          break;
        case false:
          model.startRecording();
          break;
      }
    }

    final _bodySection =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            model.isRecording
                ? Text(
                    model.recorderTxt,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : Text(
                    model.playerText,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
            Center(
              child: Builder(
                builder: (context) {
                  return Material(
                    shape: CircleBorder(),
                    color: Colors.brown,
                    elevation: 4.0,
                    child: Container(
                      height: 150.0,
                      width: 150.0,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: IconButton(
                        icon: model.isRecording
                            ? Icon(
                                Icons.stop,
                                color: Colors.white,
                                size: 80.0,
                              )
                            : Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 80.0,
                              ),
                        onPressed: () => _handleRecording(context, model),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]);
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(APP_NAME),
      ),
      backgroundColor: Colors.brown,
      body: _bodySection /*RecordingBody()*/,
    );
  }
}
