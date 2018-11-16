// import 'package:audioplayers/audioplayers.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:intl/intl.dart' show DateFormat;

const _tag = 'PlayerModel:';

abstract class PlayerModel extends Model {
  final Firestore _database = Firestore.instance;
  FlutterSound flutterSound = FlutterSound();
  StreamSubscription _playerSubscription;

  // AudioPlayer audioPlayer = AudioPlayer();
  Map<String, Recording> _recordings = Map();
  Map<String, Recording> get recordings => _recordings;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  StatusCode _playerStatus;
  StatusCode get playerStatus => _playerStatus;
  bool _isPaused = false;
  bool get isPaused => _isPaused;
  String _playerTxt = '00:00:00';
  String get playerText => _playerTxt;

  Future<StatusCode> getRecordings() async {
    print('$_tag at getRecordings');
    bool _hasError = false;
    QuerySnapshot snapshot = await _database
        .collection(RECORDINGS_COLLECTION)
        .getDocuments()
        .catchError((error) {
      print('$_tag error on getting recordings');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    List<DocumentSnapshot> documents = snapshot.documents;
    Map<String, Recording> tempMap = <String, Recording>{};
    documents.forEach((document) {
      Recording recording = Recording.fromSnaspshot(document);
      tempMap.putIfAbsent(recording.id, () => recording);
    });
    _recordings = tempMap;
    return StatusCode.success;
  }

  Future<void> play(Recording recording) async {
    print('$_tag at play');
    stop();
    String path = await flutterSound
        .startPlayer(recording == null ? null : recording.recordingUrl);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $path');

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt());
          String txt = DateFormat('mm:ss:SS', 'en_US').format(date);

          // this._isPlaying = true;
          this._playerTxt = txt.substring(0, 8);
          _isPaused = false;
          notifyListeners();
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  Future<void> pause() async {
    print('$_tag at pause');
    String result = await flutterSound.pausePlayer();
    _isPaused = true;
    notifyListeners();
    print('pausePlayer: $result');
  }

  Future<void> resume() async {
    print('$_tag at resume');
    String result = await flutterSound.resumePlayer();
    _isPaused = false;
    notifyListeners();
    print('resumePlayer: $result');
  }

  Future<void> stop() async {
    print('$_tag at stop');
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      // this._isPlaying = false;
      _isPaused = false;
      _playerTxt = '00:00:00';
      notifyListeners();
    } catch (err) {
      print('error: $err');
    }
  }
}
