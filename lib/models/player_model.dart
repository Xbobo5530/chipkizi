// import 'package:audioplayers/audioplayers.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
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

  List<Recording> _userRecordingsList = <Recording>[];

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

  Future<PlaybackStatus> play(Recording recording) async {
    print('$_tag at play');
    stop();
    PlaybackStatus _playbackStatus;
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

          if (e.currentPosition == 0.0)
            _playbackStatus = PlaybackStatus.stopped;
          if (e.currentPosition > 0.0) _playbackStatus = PlaybackStatus.playing;
        }

        _playerSubscription.onDone(() {
          _playbackStatus = PlaybackStatus.stopped;
        });
      });
      return _playbackStatus;
    } catch (err) {
      print('error: $err');
      return null;
    }
  }

  Future<PlaybackStatus> getPlayStatusFor(Recording recording) async {
    print('$_tag at getPlayStatusFor');
    PlaybackStatus _playbackStatus;
    _playerSubscription =
        flutterSound.onPlayerStateChanged.listen((PlayStatus playStatus) {
      if (playStatus == null) _playbackStatus = PlaybackStatus.stopped;
      if (playStatus.currentPosition == 0.0)
        _playbackStatus = PlaybackStatus.stopped;
      if (playStatus.currentPosition > 0.0)
        _playbackStatus = PlaybackStatus.playing;
      // print('$_tag playbackStatus is: $_playbackStatus');
    });

    _playerSubscription.onDone(() {
      _playbackStatus = PlaybackStatus.stopped;
      _playerSubscription.cancel();
      // print('$_tag playbackStatus is: $_playbackStatus');
    });
    print('$_tag playbackStatus is: $_playbackStatus');
    return _playbackStatus;
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

  Future<List<Recording>> getUserRecordings(User user, ListType type) async {
    print('$_tag at getUserRecordings');
    bool _hasError = false;

    QuerySnapshot snapshot = await _database
        .collection(USERS_COLLECTION)
        .document(user.id)
        .collection(type == ListType.bookmarks
            ? BOOKMARKS_COLLETION
            : RECORDINGS_COLLECTION)
        .getDocuments()
        .catchError((error) {
      print('$_tag error on getting user recordings documents $error');
      _hasError = true;
    });
    if (_hasError) return null;
    List<Recording> tempList = <Recording>[];
    List<DocumentSnapshot> documents = snapshot.documents;
    // print('$_tag list has ${documents.length} recordings');
    documents.forEach((document) async {
      String recordingId = document.documentID;
      Recording recording = recordings[recordingId];

      tempList.add(recording);
    });
    // print('$_tag list has ${recordingsList.length} recordings');
    _userRecordingsList = tempList;
    print('$_tag list has ${_userRecordingsList.length} recordings');
    return _userRecordingsList;
  }

  List<Recording> getAllRecordings(Recording recording) {
    print('$_tag at getAllRecordings');
    List<Recording> tempList = <Recording>[];
    List<String> ids = recordings.keys.toList();
    ids.remove(recording.id);
    ids.shuffle();
    ids.insert(0, recording.id);
    ids.forEach((id) {
      Recording _recording = recordings[id];
      tempList.add(_recording);
    });

    return tempList;
  }
}
