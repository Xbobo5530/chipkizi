import 'package:chipkizi/mock_data/recording_data.dart';
import 'package:chipkizi/pages/create_recording.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recording_body.dart';
import 'package:chipkizi/views/recordings_list_item.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';



class HomePage extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    _openRecordingPage(BuildContext context) {
    Navigator.push(
        context,
         MaterialPageRoute(
            builder: (context) =>  RecordingPage(), fullscreenDialog: true));
  }
    
    
    return  Scaffold(
      appBar:  AppBar(
        leading: Icon(Icons.mic_none),
        title:  Text(APP_NAME),
        actions: <Widget>[

        ],
      ),
      body:  ListView.builder(
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          
          return  ListTile(title: Text(recordings[index].title),);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(items: <BottomNavigationBarItem>[],),
      floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.mic),
                  heroTag: 'open recording page',
                  onPressed: () => _openRecordingPage(context)),,

    );
  }
}
