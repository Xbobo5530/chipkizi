import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/player_recording_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class PlayerPage extends StatelessWidget {
  final Recording recording;
  final List<Recording> recordings;

  const PlayerPage({Key key, this.recording, this.recordings})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // print(recordings);
    final _recordingFromNetwork = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return FutureBuilder<Recording>(
            future: model.getRecordingFromId(recording.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: MyProgressIndicator(
                    color: Colors.white,
                    size: 28.0,
                    value: null,
                  ),
                );
              return RecordingCard(
                  recording: recording,
                  key: Key(
                    recording.id,
                  ));
            });
      },
    );
    final _recordingSection = SafeArea(
      child: PageView(
        children: recording == null
            ? _recordingFromNetwork
            : recordings
                .map((recording) => RecordingCard(
                    recording: recording,
                    key: Key(
                      recording.id,
                    )))
                .toList(),
      ),
    );

    final _appBar = AppBar(
      elevation: 0.0,
      leading: Hero(
        tag: 'TAG_MAIN_BUTTON',
        child: Material(
          color: Colors.transparent,
          child: Container(),
        ),
      ),
      title: Hero(
        tag: TAG_APP_TITLE,
        child: Text(APP_NAME),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.brown,
      //appBar: _appBar,
      body: _recordingSection,
    );
  }
}
