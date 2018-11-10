import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
//import 'package:intl/date_symbol_data_local.dart';

const _tag = 'RecordingModel:';

abstract class RecordingModel extends Model {
  final FlutterSound flutterSound = new FlutterSound();
  final Firestore _database = Firestore.instance;

  StatusCode _uploadStatus;
  StatusCode get uploadStatus => _uploadStatus;
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  var _playerSubscription;

  String _playerTxt = '00:00:00';
  String get playerText => _playerTxt;

  Future<StatusCode> uploadRecording(Recording recoding) async {
    // TODO: handle recording
  }

  Future<StatusCode> deleteRecording(Recording recoding) async {
    // TODO: handle delete recording
  }

  Future<StatusCode> startRecording() async {
    print('$_tag at startRecording');
    String path = await flutterSound.startPlayer(null);
    print('startPlayer: $path');
    _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
      if (e != null) {
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        // String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
        final txt = '${date.minute}: ${date.second}: ${date.millisecond}';
        _isPlaying = true;
        _playerTxt = txt;
        notifyListeners();
      }
    });
  }

  Future<StatusCode> stopRecording(Recording recoding) async {}

  Future<StatusCode> pauseRecording(Recording recoding) async {
    // TODO: handle recording
  }
}
