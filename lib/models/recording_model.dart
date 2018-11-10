import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

abstract class RecordingModel extends Model{
  final Firestore _database = Firestore.instance;

  StatusCode _uploadStatus;
  StatusCode get uploadStatus => _uploadStatus;
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Future<StatusCode> uploadRecording(Recording recoding)async{
    // TODO: handle recording
  }

  Future<StatusCode> deleteRecording(Recording recoding)async{
    // TODO: handle delete recording
  }

  Future<StatusCode> startRecording(Recording recoding)async{
    // TODO: handle recording
  }

  Future<StatusCode> stopRecording(Recording recoding)async{
    // TODO: handle recording
  }

  Future<StatusCode> pauseRecording(Recording recoding)async{
    // TODO: handle recording
  }



}