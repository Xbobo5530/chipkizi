import 'package:chipkizi/mock_data/recording_data.dart';
import 'package:chipkizi/pages/create_recording.dart';
import 'package:chipkizi/views/recordings_list_item.dart';
import 'package:flutter/material.dart';

class HomeBodyView extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBodyView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (BuildContext context, int index) {
                return new RecordingsListItemView(recordings[index]);
              },
            ),
          ),
        ),
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new FloatingActionButton(
                  child: Icon(Icons.mic),
                  heroTag: 'open recording page',
                  onPressed: () => _openRecordingPage(context)),
            ],
          ),
        )
      ],
    );
  }

  _openRecordingPage(BuildContext context) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new RecordingPage(), fullscreenDialog: true));
  }
}
