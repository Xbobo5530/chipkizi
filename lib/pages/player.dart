import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/player_recording_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'PlayerPage:';

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
                    color: Colors.white70,
                    size: 32.0,
                    value: null,
                    strokeWidth: 4.0,
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
      child: ScopedModelDescendant<MainModel>(
        builder: (_, __, model) {
          /// fail safe
          /// if recordings are added by others
          /// [updateRecordings(Recording recording)]
          /// should be ran to add new recordings to the cache
          if (!model.recordings.containsKey(recording.id))
            model.updateRecordings(recording);

          print('$_tag the selected recording id is: ${recording.id}');

          return PageView(
            children: recordings == null
                ? <Widget>[_recordingFromNetwork]
                : recordings
                    .map((recording) => RecordingCard(
                        recording: recording,
                        key: Key(
                          recording.id,
                        )))
                    .toList(),
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: Colors.brown,
      //appBar: _appBar,
      body: _recordingSection,
    );
  }
}
