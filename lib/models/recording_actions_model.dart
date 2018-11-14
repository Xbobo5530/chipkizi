import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
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

  StatusCode _bookmarkingStatus;
  StatusCode get bookmarkingStatus => _bookmarkingStatus;

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

  DocumentReference _getUpvoteDocumentRefFor(
      Recording recording, User user) {
    return _database
        .collection(RECORDINGS_COLLECTION)
        .document(recording.id)
        .collection(UPVOTES_COLLETION)
        .document(user.id);
  }

  Future<StatusCode> hanldeUpvoteRecording(
      Recording recording, User user) async {
    print('$_tag at upvoteRecording');
    _upvotingRecordingStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;

    /// check if use has already upvoted
    /// if has upvoted, update upvote count by [user]
    /// if has not upvoted create upvote doc
    /// update [recording]'s [upvotes] field
    DocumentSnapshot document =
        await _getUpvoteDocumentRefFor(recording, user)
            .get()
            .catchError((error) {
      print('$_tag error on getting user upvote document: $error');
      _hasError = true;
    });
    if (_hasError) {
      _upvotingRecordingStatus = StatusCode.failed;
      notifyListeners();
      return _upvotingRecordingStatus;
    }
    if (document.exists) {
      _upvotingRecordingStatus = await _addVote(recording, user);
      notifyListeners();
      return _upvotingRecordingStatus;
    }
    _upvotingRecordingStatus = await _createVote(recording, user);
    notifyListeners();
    return _upvotingRecordingStatus;
  }

  Future<StatusCode> _addVote(Recording recording, User user) async {
    print('$_tag at _addVote');
    bool _hasError = false;
    await _database.runTransaction((transaction) async {
      DocumentSnapshot freshSnapshot =
          await transaction.get(_getUpvoteDocumentRefFor(recording, user));
      await transaction.update(freshSnapshot.reference,
          {UPVOTE_COUNT_FIELD: freshSnapshot[UPVOTE_COUNT_FIELD] + 1});
    }).catchError((error) {
      print('$_tag failed to do transaction to update user vote: $error');
    });
    if (_hasError) return StatusCode.failed;
    return await _updateRecordingVotes(recording);
  }

  Future<StatusCode> _createVote(Recording recording, User user) async {
    print('$_tag at _createVote');
    bool _hasError = false;
    Map<String, dynamic> upvoteMap = {
      RECORDING_ID_FIELD: recording.id,
      CREATED_BY_FIELD: user.id,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch,
      UPVOTE_COUNT_FIELD: 1
    };
    await _getUpvoteDocumentRefFor(recording, user)
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

  Future<bool> hasUpvoted(Recording recording, User user)async{
    print('$_tag at hasUpvoted');
    bool _hasError = false;
    DocumentSnapshot document =  await _getUpvoteDocumentRefFor(recording, user).get()
    .catchError((error){
      print('$_tag error on getting upvote doc: $error');
      _hasError = true;
    });
    if (_hasError || !document.exists) return false;
    return true;
  }

  DocumentReference _getBookmarkDocumentRerFor(Recording recording, User user) {
    return _database
        .collection(USERS_COLLECTION)
        .document(user.id)
        .collection(BOOKMARKS_COLLETION)
        .document(recording.id);
  }

  Future<StatusCode> handleBookbarkRecording(
      Recording recording, User user) async {
    print('$_tag at handleBookbarkRecording');
    _bookmarkingStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    DocumentSnapshot document =
        await _getBookmarkDocumentRerFor(recording, user)
            .get()
            .catchError((error) {
      print('$_tag error on getting bookbarck document');
      _hasError = true;
    });
    if (_hasError) {
      _bookmarkingStatus = StatusCode.failed;
      notifyListeners();
      return _bookmarkingStatus;
    }
    if (document.exists) {
      _bookmarkingStatus = await _deleteBookmarkDoc(document);
      notifyListeners();
      return _bookmarkingStatus;
    }
    _bookmarkingStatus = await _createBookmarkDoc(recording, user);
    notifyListeners();
    return _bookmarkingStatus;
  }

  Future<StatusCode> _deleteBookmarkDoc(DocumentSnapshot document) async {
    print('$_tag at _deleteBookmarkDoc');
    bool _hasError = false;
    document.reference.delete().catchError((error) {
      print('$_tag error on deleting bookmark document: $error');
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<StatusCode> _createBookmarkDoc(Recording recording, User user)async{
    print('$_tag at _createBookmarkDoc');
    bool _hasError = false;
    Map<String, dynamic> bookmarkMap = {
      CREATED_AT_FIELD : DateTime.now().millisecondsSinceEpoch,
      CREATED_BY_FIELD : user.id,
      RECORDING_ID_FIELD : recording.id
    };
    await _getBookmarkDocumentRerFor(recording, user).setData(bookmarkMap).catchError((error){
      print('$_tag error on creating bookmark doc: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<bool> hasBookmarked(Recording recording, User user)async{
    print('$_tag at hasUpvoted');
    bool _hasError = false;
    DocumentSnapshot document =  await _getBookmarkDocumentRerFor(recording, user).get()
    .catchError((error){
      print('$_tag error on getting bookmark doc: $error');
      _hasError = true;
    });
    if (_hasError || !document.exists) return false;
    return true;
  }

  
}
