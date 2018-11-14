import 'package:audioplayers/audioplayers.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'PlayerModel:';
abstract class PlayerModel extends Model{

  final Firestore _database = Firestore.instance;

  AudioPlayer audioPlayer = AudioPlayer();

  String _currentPlaybackUrl;

  Map<String, Recording> _recordings = Map();
  Map<String, Recording> get recordings => _recordings;



bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  StatusCode _playerStatus;
  StatusCode get playerStatus => _playerStatus;


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
  

  void resetPlayer(){
    stopPlayer();
    _isPlaying = false;
    _playerStatus = StatusCode.success;
    notifyListeners();
  }

  Future<StatusCode> playFromUrl(String url) async {
    print('$_tag at playFromUrl\nurl is: $url');
    _playerStatus = StatusCode.waiting;
    notifyListeners();
    // if (url == _currentPlaybackUrl) {
    //   _playerStatus = await resumePlayer();
    //   notifyListeners();
    //   return _playerStatus;
    // }
    url = _currentPlaybackUrl;
    bool _hasError = false;
    int result = await audioPlayer.play(url);
    if (result != 1) {
      print('$_tag error on playing from url: status is $result');
      _hasError = true;
    }

    if (_hasError) {
      _playerStatus = StatusCode.failed;
      notifyListeners();
      return _playerStatus;
    }

    _playerStatus = StatusCode.success;
    notifyListeners();
    return _playerStatus;
  }
  Future<StatusCode> pausePlayer() async {
    print('$_tag at pausePlayer');
    bool _hasError = false;
    int result = await audioPlayer.pause();
    if (result != 1) {
      _hasError = true;
      print('$_tag error on pausing player playback');
    }
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<StatusCode> resumePlayer() async {
    print('$_tag at resumePlayer');
    bool _hasError = false;
    int result = await audioPlayer.resume();
    if (result != 1) {
      _hasError = true;
      print('$_tag error on resuming player playback');
    }
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<StatusCode> stopPlayer() async {
    print('$_tag at stopPlayer');
    bool _hasError = false;
    int result = await audioPlayer.stop();
    if (result != 1) {
      _hasError = true;
      print('$_tag error on stopping player playback');
    }
    if (_hasError) return StatusCode.failed;
    _isPlaying = false;
    notifyListeners();
    _playerStatus = StatusCode.success;
    return _playerStatus;
  }

  
}