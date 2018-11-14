import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'RecordingActionsModel:';

abstract class RecordingActionsModel extends Model {
  final Firestore _database = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage();

  StatusCode _upvotingRecordingStatus;
  StatusCode get upvotingRecordingStatus => _upvotingRecordingStatus;

  StatusCode _deletingRecordingStatus;
  StatusCode get deletingRecordingStatus => _deletingRecordingStatus;

  Future<StatusCode> deleteRecording(Recording recording, String userId) async {
    print('$_tag at deleteRecording');
    _deletingRecordingStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    if (recording.createdBy != userId) {
      _deletingRecordingStatus = StatusCode.failed;
      notifyListeners();
      return _deletingRecordingStatus;
    }
    await _database
        .collection(RECORDINGS_COLLECTION)
        .document(recording.id)
        .delete()
        .catchError((error) {
      print('$_tag error on deleting a recording document');
    });

    if (_hasError) {
      _deletingRecordingStatus = StatusCode.failed;
      notifyListeners();
      return _deletingRecordingStatus;
    }
    _deletingRecordingStatus = await _deleteFile(recording);
    notifyListeners();
    return _deletingRecordingStatus;
  }

  Future<StatusCode> _deleteFile(Recording recording) async {
    print('$_tag at _deleteFile');
    bool _hasError = false;
    storage
        .ref()
        .child(RECORDINGS_BUCKET)
        .child(recording.recordingPath)
        .delete()
        .catchError((error) {
      print('$_tag error on deleting the file');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  DocumentReference getDocumentRefFor(Recording recording, String userId) {
    return _database
        .collection(RECORDINGS_COLLECTION)
        .document(recording.id)
        .collection(UPVOTES_COLLETION)
        .document(userId);
  }

  Future<StatusCode> hanldeUpvoteRecording(
      Recording recording, String userId) async {
    print('$_tag at upvoteRecording');
    _upvotingRecordingStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;

    /// check if use has already upvoted
    /// if has upvoted, update upvote count by [user]
    /// if has not upvoted create upvote doc
    /// update [recording]'s [upvotes] field
    DocumentSnapshot document =
        await getDocumentRefFor(recording, userId).get().catchError((error) {
      print('$_tag error on getting user upvote document: $error');
      _hasError = true;
    });
    if (_hasError) {
      _upvotingRecordingStatus = StatusCode.failed;
      notifyListeners();
      return _upvotingRecordingStatus;
    }
    if (document.exists) {
      _upvotingRecordingStatus = await _addVote(recording, userId);
      notifyListeners();
      return _upvotingRecordingStatus;
    }
    _upvotingRecordingStatus = await _createVote(recording, userId);
    notifyListeners();
    return _upvotingRecordingStatus;
  }

  Future<StatusCode> _createVote(Recording recording, String userId) async {
    print('$_tag at _addVote');
    bool _hasError = false;
    Map<String, dynamic> upvoteMap = {
      RECORDING_ID_FIELD: recording.id,
      CREATED_BY_FIELD: userId,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch,
      UPVOTE_COUNT_FIELD: 1
    };
    await getDocumentRefFor(recording, userId)
        .setData(upvoteMap)
        .catchError((error) {
      print('$_tag error on creating the upvote document: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return await _updateRecordingVotes(recording);
  }

  Future<StatusCode> _updateRecordingVotes(Recording recording) async {
    print('$_tag at _updateRecordingVotes');
    bool _hasError = false;
    await _database.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(
          _database.collection(RECORDINGS_COLLECTION).document(recording.id));
      await transaction.update(freshSnap.reference,
          {UPVOTE_COUNT_FIELD: freshSnap[UPVOTE_COUNT_FIELD] + 1});
    }).catchError((error) {
      print('$_tag error on updating recording upvotes: $error');
      _hasError = true;
    });

    if (_hasError) return StatusCode.failed;

    return StatusCode.success;
  }
}
