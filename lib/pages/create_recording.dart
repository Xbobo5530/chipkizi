import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_buttom.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
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
            CircularIconButton(
              button: IconButton(
                icon: Icon(
                  Icons.pause,
                  color: Colors.orange,
                ),
                onPressed: () => model.pausePlayback(),
              ),
              color: Colors.white,
            ),
            CircularIconButton(
              button: IconButton(
                icon: Icon(
                  Icons.play_arrow,
                  color: Colors.green,
                ),
                onPressed: () => model.playPlayback(),
              ),
              color: Colors.white,
            ),
            CircularIconButton(
              button: IconButton(
                icon: Icon(Icons.stop, color: Colors.red),
                onPressed: () => model.stopPlayback(),
              ),
              color: Colors.white,
            ),
          ],
        ));

    _handleRecording(BuildContext context, MainModel model) {
      switch (model.isRecording) {
        case true:
          model.stopRecording();

          break;
        case false:
          model.startRecording();
          break;
      }
    }

//    Widget _buildRecordButton(MainModel model) =>

    Widget _buildRecordButton(MainModel model) => Expanded(
          child: Center(
            child: Builder(
              builder: (context) {
                return Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0.0,
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: MyProgressIndicator(
                        size: 50.0,
                        color: Colors.red,
                        progress: model.recorderProgress,
                      ),
                    ),
                    Material(
                      shape: CircleBorder(),
                      color: Colors.white,
                      elevation: 4.0,
                      child: Container(
                        height: 150.0,
                        width: 150.0,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: IconButton(
                          icon: model.isRecording
                              ? Icon(
                                  Icons.stop,
                                  color: Colors.brown,
                                  size: 80.0,
                                )
                              : Icon(
                                  Icons.fiber_manual_record,
                                  color: Colors.red,
                                  size: 80.0,
                                ),
                          onPressed: () => _handleRecording(context, model),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );

    final _waitButton = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
            onPressed: null,
            child: Text(
              waitText,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ))
      ],
    );

    final _bodySection =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRecordButton(model),
            model.isRecording ? _waitButton : _buildPlayerControls(model)
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
