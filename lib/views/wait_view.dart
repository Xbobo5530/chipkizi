import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/pages/player.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/progress_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class WaitView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildProgressButton(MainModel model) => ProgressButton(
          color: Colors.white,
          button: IconButton(
            onPressed: () {},
            icon: model.uploadStatus == StatusCode.success
                ? Icon(
                    Icons.done,
                    size: 80.0,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.file_upload,
                    size: 80.0,
                  ),
          ),
          size: 150.0,
          indicator: model.uploadStatus == StatusCode.success
              ? Container()
              : MyProgressIndicator(
                  color: Colors.orange,
                  value: null,
                  size: 150.0,
                ),
        );

    Widget _buildTextSection(MainModel model) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            model.uploadStatus == StatusCode.success
                ? submitSuccessText
                : waitText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        );

    final _homeButton = RaisedButton(
      color: Colors.white,
      textColor: Colors.brown,
      child: Text(goHomeText),
      onPressed: () {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      },
    );

    Widget _buildPlayerButton(MainModel model) => RaisedButton(
          color: Colors.white,
          textColor: Colors.brown,
          child: Text(openRecordingText),
          onPressed: () async {
            Recording newRecording = model.lastSubmittedRecording;
            List<Recording> recordings = model.getAllRecordings(newRecording);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerPage(
                        recording: newRecording,
                        recordings: recordings,
                      ),
                ),
                ModalRoute.withName('/'));
          },
        );

    Widget _buildActions(MainModel model) => ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            _homeButton,
            _buildPlayerButton(model),
          ],
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        if (model.uploadStatus == StatusCode.success)
          model.updateRecordings(model.lastSubmittedRecording);
        return Scaffold(
            backgroundColor: Colors.brown,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildProgressButton(model),
                  _buildTextSection(model),
                  model.uploadStatus == StatusCode.success
                      ? _buildActions(model)
                      : Container(),
                ],
              ),
            ));
      },
    );
  }
}
