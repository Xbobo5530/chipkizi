import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/player_recording_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';


const _tag = 'PlayerPage:';

class PlayerPage extends StatelessWidget {
  final Recording recording;

  const PlayerPage({Key key, this.recording}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _recordingSection =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return PageView.builder(
        // onPageChanged: (pageNumber)=> model.resetPlayer(),
        itemCount: model.recordings.length - 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0)
            return RecordingCard(
              recording: this.recording,
            );
          List<String> recordingsIds = model.recordings.keys.toList();
          recordingsIds.remove(this.recording.id);
          // recordingsIds.shuffle();
          Recording recording = model.recordings[recordingsIds[index]];
          return RecordingCard(
            recording: recording,
          );
        },
      );
    });

    final _appBar = AppBar(
      elevation: 0.0,
      leading: Hero(
        tag: TAG_MAIN_BUTTON,
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Hero(
        tag: TAG_APP_TITLE,
        child: Text(APP_NAME),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: _appBar,
      body: _recordingSection,
    );
  }
}
