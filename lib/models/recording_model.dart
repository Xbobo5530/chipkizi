import 'dart:async';
import 'package:chipkizi/values/consts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';


const _tag = 'RecordingModel:';

abstract class RecordingModel extends Model {
  final Firestore _database = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage();
//  AudioCache audioCache =  AudioCache();

  

  List<String> _selectedGenres = <String>[];

  Stream<QuerySnapshot> recordingsStream =
      Firestore.instance.collection(RECORDINGS_COLLECTION).snapshots();

  String _defaultRecordingPath;
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  String _recordingUrl;
  String _recordingPath;

  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound = FlutterSound();

  StatusCode _submitStatus;
  StatusCode get uploadStatus => _submitStatus;
  StatusCode _editingRecordingDetailsStatus;
  StatusCode get editingRecordingDetailsStatus => _editingRecordingDetailsStatus;
  bool _isEditingRecordingTitle = false;
  bool get isEditingTitle => _isEditingRecordingTitle;
  bool _isEditingRecordingDesc = false;
  bool get isEditingRecordingDesc => _isEditingRecordingDesc;
  
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  String _recorderTxt = '00:00:00';
  String get recorderTxt => _recorderTxt;

  
  bool _isPaused = false;
  bool get isPaused => _isPaused;

  
  String _playerTxt = '00:00:00';
  String get playerText => _playerTxt;

  double _recorderProgress = 0.0;
  double get recorderProgress => _recorderProgress;

//  FlutterSound flutterSound;

//  flutterSound.setSubscriptionDuration(0.01);

  Map<String, bool> genres = <String, bool>{
    'Gospel': false,
    'Hip-hop': false,
    'Bongo flava': false,
    'Bakurutu': false,
    'Poem': false,
    'Spoken word': false,
    'R&B': false,
    'Speech': false,
    'Music': false,
    'Other': false,
  };

  

  void updateGenres(int index) {
    genres.update(genres.keys.elementAt(index),
        (isSelected) => isSelected ? false : true);
    notifyListeners();
  }

  

  

  

  

  

  

  Future<StatusCode> handleSubmit(Recording recording) async {
    print('$_tag at handle submit recording');
    _submitStatus = StatusCode.waiting;
    notifyListeners();
    StatusCode uploadRecordingStatus = await _uploadRecording();

    if (uploadRecordingStatus == StatusCode.failed) {
      print('$_tag error on handling submit');
      _submitStatus = StatusCode.failed;
      return _submitStatus;
    }
    _submitStatus = await _createRecordingDoc(recording);
    notifyListeners();
    return _submitStatus;
  }

  Future<StatusCode> _uploadRecording() async {
    print('$_tag at _uploadRecording');
    bool _hasError = false;
    final String uuid = Uuid().v1();
//    final Directory systemTempDir = Directory.systemTemp;
    final File file = File(
        _defaultRecordingPath); //File('${systemTempDir.path}/foo$uuid.txt');//.create();
//    await file.writeAsString(kTestString);
//    assert(await file.readAsString() == kTestString);
    final StorageReference ref =
        storage.ref().child(RECORDINGS_BUCKET).child('$uuid.mp4');
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'chipkizi'},
      ),
    );

    /// TODO: monitor uploads
//    _tasks.add(uploadTask);

    StorageTaskSnapshot snapshot =
        await uploadTask.onComplete.catchError((error) {
      print('$_tag error on uploading recording: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    _recordingUrl = await snapshot.ref.getDownloadURL();
    _recordingPath = await snapshot.ref.getPath();
    print('$_tag the download url is : $_recordingUrl');

    notifyListeners();
    return StatusCode.success;
  }

  Future<StatusCode> _createRecordingDoc(Recording recording) async {
    print('$_tag at _createRecordingDoc');
    bool _hasError = false;
    List<String> tempList = <String>[];
    genres.forEach((genre, isSelected) {
      if (isSelected) tempList.add(genre);
    });
    _selectedGenres = tempList;
    Map<String, dynamic> recordingMap = {
      RECORDING_URL_FIELD: _recordingUrl,
      RECORDING_PATH_FIELD: _recordingPath,
      CREATED_BY_FIELD: recording.createdBy,
      CREATED_AT_FIELD: recording.createdAt,
      TITLE_FIELD: recording.title,
      DESCRIPTION_FIELD: recording.description,
      UPVOTE_COUNT_FIELD: 0,
      PLAY_COUNT_FIELD: 0,
      GENRE_FIELD: _selectedGenres
    };
    await _database
        .collection(RECORDINGS_COLLECTION)
        .add(recordingMap)
        .catchError((error) {
      print('$_tag error on creating recording doc: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  

  Future<void> startRecording() async {
    print('$_tag at startRecording');
    try {
      String path = await flutterSound.startRecorder(null);
      print('startRecorder: $path');
      _defaultRecordingPath = path;
      notifyListeners();

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());

        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
        _recorderTxt = txt.substring(0, 8);
        int lapsedTime = date.second;
        int totalTime = 30;
        _recorderProgress = lapsedTime / totalTime;
        if (_recorderTxt == '00:30:00') stopRecording();

        print('$_recorderProgress');
        notifyListeners();
      });

      _isRecording = true;
      notifyListeners();
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  Future<void> stopRecording() async {
    print('$_tag at stopRecording');
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }

      this._isRecording = false;
      notifyListeners();
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  Future<void> playRecording() async {
    String path = await flutterSound.startPlayer(null);
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

  Future<void> pauseRecordingPlayback() async {
    String result = await flutterSound.pausePlayer();
    _isPaused = true;
    notifyListeners();
    print('pausePlayer: $result');
  }

  Future<void> resumeRecordingPlayback() async {
    String result = await flutterSound.resumePlayer();
    _isPaused = false;
    notifyListeners();
    print('resumePlayer: $result');
  }

  Future<void> stopRecordingPlayback() async {
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

  /// called when the user clicks the  edit recording details icon
  /// the [type] is a [DetailType] that will be passed to indicate
  /// which field the user is updating
  /// the [type] is for the edit recording is limited to
  /// [DetailType.title] and [DetailType.description]
  void startEditingProfile(DetailType type) {
    print('$_tag at startEditingName');
    switch (type) {
      case DetailType.title:
        _isEditingRecordingTitle = true;
        notifyListeners();
        break;
      case DetailType.description:
        _isEditingRecordingDesc = true;
        notifyListeners();
        break;
      default:
        print('$_tag unexpected type: $type');
    }
  }

  /// called to reset the is editing fields whent he user has
  /// finished editing the respective fields
  /// the [type] is a [DetailType] a function will pass
  /// to specify the field that needs reset
  /// the [type] on isEditing fields will be limited to
  /// [DetailType.title] which will reset the [_isEditingRecordingTitle] field to [false]
  /// and teh [DetailType.description] which will reset the [_isEditingRecordingDesc] field to [false]
  _resetIsEditingField (DetailType type){
    switch (type) {
      case DetailType.title:
        _isEditingRecordingTitle = false;
        break;
      case DetailType.description:
        _isEditingRecordingDesc = false;
        break;
      default:
        print('$_tag unexpected type: $type');
    }
  }

  Future<StatusCode> editRecordingDetails(Recording recording, DetailType type)async{
    print('$_tag at editRecordingDetails');
    _editingRecordingDetailsStatus = StatusCode.waiting;
    switch (type) {
      case DetailType.title:
        _isEditingRecordingTitle = true;
        break;
      case DetailType.description:
        _isEditingRecordingDesc = true;
        break;
      default:
        print('$_tag unexpected type: $type');
    }
    notifyListeners();
    bool _hasError = false;
    Map<String, dynamic> detailMap = Map();
    switch (type) {
      case DetailType.title:
        detailMap.putIfAbsent(TITLE_FIELD, () => recording.title);
        break;
      case DetailType.description:
        detailMap.putIfAbsent(DESCRIPTION_FIELD, () => recording.description);
        break;
      default:
        print('$_tag unexpected detail type: $type');
    }
    await _database
        .collection(RECORDINGS_COLLECTION)
        .document(recording.id)
        .updateData(detailMap)
        .catchError((error) {
      print('$_tag error on updating user details: $error');
      _editingRecordingDetailsStatus = StatusCode.failed;
      _hasError = true;
      _resetIsEditingField(type);
      notifyListeners();
    });
    if (_hasError) return _editingRecordingDetailsStatus;
    _editingRecordingDetailsStatus = StatusCode.success;
    _resetIsEditingField(type);
    notifyListeners();
    return _editingRecordingDetailsStatus;
  }
  
}
