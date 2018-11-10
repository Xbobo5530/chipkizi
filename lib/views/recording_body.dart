//import 'dart:io' as io;
//import 'dart:math';
//
//import 'package:audio_recorder/audio_recorder.dart';
//import 'package:audioplayers/audioplayers.dart';
//import 'package:chipkizi/views/player_widget.dart';
//import 'package:file/file.dart';
//import 'package:file/local.dart';
//import 'package:flutter/material.dart';
//import 'package:path_provider/path_provider.dart';
//
//class RecordingBody extends StatefulWidget {
//  final LocalFileSystem localFileSystem;
//
//  RecordingBody({localFileSystem})
//      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
//  @override
//  _HomeBodyState createState() => _HomeBodyState();
//}
//
//class _HomeBodyState extends State<RecordingBody> {
//  Recording _recording = new Recording();
//  bool _isRecording = false;
//  Random random = new Random();
//  TextEditingController _controller = new TextEditingController();
//  @override
//  Widget build(BuildContext context) {
//    return Center(
//      child: Column(
//        children: <Widget>[
//          new FlatButton(
//            onPressed: _isRecording ? null : _start,
//            child: new Text("Start"),
//            color: Colors.green,
//          ),
//          new FlatButton(
//            onPressed: _isRecording ? _stop : null,
//            child: new Text("Stop"),
//            color: Colors.red,
//          ),
//          new TextField(
//            controller: _controller,
//            decoration: new InputDecoration(
//              hintText: 'Enter a custom path',
//            ),
//          ),
//          new Text("File path of the record: ${_recording.path}"),
//          new Text("Format: ${_recording.audioOutputFormat}"),
//          new Text("Extension : ${_recording.extension}"),
//          new Text(
//              "Audio recording duration : ${_recording.duration.toString()}"),
//          new Divider(),
//          FlatButton(
//              onPressed: () {
//                _playLocal(
//                    '/Users/Sean/Library/Developer/CoreSimulator/Devices/45B31E8E-4783-4155-89A2-5F4780D56560/data/Containers/Data/Application/AEA7AAF5-47E0-4281-A328-F16C1062CB2F/Documents/1537999377.m4a' /*_recording.path*/);
//              },
//              child: Text('Play'))
////          new PlayerWidget(
////            url: _recording.path,
////            isLocal: true,
////          )
//        ],
//      ),
//    );
//  }
//
//  _start() async {
//    try {
//      if (await AudioRecorder.hasPermissions) {
//        if (_controller.text != null && _controller.text != "") {
//          String path = _controller.text;
//          if (!_controller.text.contains('/')) {
//            io.Directory appDocDirectory =
//                await getApplicationDocumentsDirectory();
//            path = appDocDirectory.path + '/' + _controller.text;
//          }
//          print("Start recording: $path");
//          await AudioRecorder.start(
//              path: path, audioOutputFormat: AudioOutputFormat.AAC);
//        } else {
//          await AudioRecorder.start();
//        }
//        bool isRecording = await AudioRecorder.isRecording;
//        setState(() {
//          _recording = new Recording(duration: new Duration(), path: "");
//          _isRecording = isRecording;
//        });
//      } else {
//        Scaffold.of(context).showSnackBar(
//            new SnackBar(content: new Text("You must accept permissions")));
//      }
//    } catch (e) {
//      print(e);
//    }
//  }
//
//  _stop() async {
//    var recording = await AudioRecorder.stop();
//    print("Stop recording: ${recording.path}");
//    bool isRecording = await AudioRecorder.isRecording;
//    File file = widget.localFileSystem.file(recording.path);
//    print("  File length: ${await file.length()}");
//    setState(() {
//      _recording = recording;
//      _isRecording = isRecording;
//    });
//    _controller.text = recording.path;
//  }
//
//  _playLocal(String path) async {
//    AudioPlayer audioPlayer = new AudioPlayer();
//    int result = await audioPlayer.play(path, isLocal: true);
//  }
//}
