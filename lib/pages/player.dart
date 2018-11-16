import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/player_recording_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';




class PlayerPage extends StatelessWidget {
  final Recording recording;
  final List<Recording> recordings;

  const PlayerPage({Key key, this.recording, this.recordings}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _recordingSection = PageView(
      children: recordings.map((recording) => RecordingCard(
              recording: recording,
            )).toList(),
    );
    
    
    // .builder(
    //     // onPageChanged: (pageNumber)=> model.resetPlayer(),
    //     itemCount: recordings.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       if (index == 0)
    //         return RecordingCard(
    //           recording: recording,
    //         );
    //       // List<String> recordingsIds = model.recordings.keys.toList();
    //       // recordingsIds.remove(this.recording.id);
    //       // recordingsIds.shuffle();
    //       // Recording recording = model.recordings[recordingsIds[index]];
    //       return RecordingCard(
    //         recording: recordings[index],
    //       );
    //     },
    //   );

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
