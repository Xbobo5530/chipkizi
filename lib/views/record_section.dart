import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/progress_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordSectionView extends StatelessWidget {
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
                onPressed: () => model.pauseRecordingPlayback(),
              ),
              color: Colors.white,
            ),
            CircularIconButton(
              button: IconButton(
                icon: Icon(
                  Icons.play_arrow,
                  color: Colors.green,
                ),
                onPressed: () => model.playRecording(),
              ),
              color: Colors.white,
            ),
            CircularIconButton(
              button: IconButton(
                icon: Icon(Icons.stop, color: Colors.red),
                onPressed: () => model.stopRecordingPlayback(),
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

    Widget _buildRecordButton(MainModel model) => Expanded(
          child: Center(
            child: Builder(
              builder: (context) {
                return Hero(
                  tag: TAG_MAIN_BUTTON,
                  child: ProgressButton(
                    indicator: MyProgressIndicator(
                      size: 50.0,
                      color: Colors.red,
                      value: model.recorderProgress,
                    ),
                    button: IconButton(
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
                    size: 150.0,
                    color: Colors.white,
                  ),
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

    return ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRecordButton(model),
            model.isRecording ? _waitButton : _buildPlayerControls(model)
          ]);
    });
  }
}
