import 'package:chipkizi/models/comment.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'CommentModel:';

abstract class CommentModel extends Model {
  final Firestore _database = Firestore.instance;

  StatusCode _submittingCommentStatus;
  StatusCode get submittingCommentStatus => _submittingCommentStatus;

  Future<StatusCode> submitComment(Comment comment) async {
    print('$_tag at submitComment');
    _submittingCommentStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    Map<String, dynamic> commentMap = {
      MESSAGE_FIELD: comment.message,
      CREATED_BY_FIELD: comment.createdBy,
      CREATED_AT_FIELD: comment.createdAt,
      RECORDING_ID_FIELD: comment.recordingId,
      IS_MODIFIED_FIELD: VAL_NOT_MODIFIED
    };
    await _database
        .collection(RECORDINGS_COLLECTION)
        .document(comment.recordingId)
        .collection(COMMENTS_COLLECTION)
        .add(commentMap)
        .catchError((error) {
      print('$_tag error on submitting comment: $error');
      _hasError = true;
      _submittingCommentStatus = StatusCode.failed;
      notifyListeners();
    });
    if (_hasError) return _submittingCommentStatus;
    _submittingCommentStatus = StatusCode.success;
    notifyListeners();
    return _submittingCommentStatus;
  }

  Future<StatusCode> editComment(Comment comment) async {
    print('$_tag at editComment');
    _submittingCommentStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    Map<String, dynamic> updateMap = {
      MESSAGE_FIELD: comment.message,
      IS_MODIFIED_FIELD: VAL_IS_MODIFIED
    };
    await _database
        .collection(RECORDINGS_COLLECTION)
        .document(comment.id)
        .collection(COMMENTS_COLLECTION)
        .document(comment.id)
        .updateData(updateMap)
        .catchError((error) {
      print('$_tag error on updating comment: $error');
      _submittingCommentStatus = StatusCode.failed;
      notifyListeners();
    });
    if (_hasError) return _submittingCommentStatus;
    _submittingCommentStatus = StatusCode.success;
    notifyListeners();
    return _submittingCommentStatus;
  }

  Future<StatusCode> deleteComment(Comment comment) async {
    print('$_tag at deleteComment:');
    bool _hasError = false;
    await _database
        .collection(RECORDINGS_COLLECTION)
        .document(comment.recordingId)
        .collection(COMMENTS_COLLECTION)
        .document(comment.id)
        .delete()
        .catchError((error) {
      print('$_tag error on deleting comment: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }
}
