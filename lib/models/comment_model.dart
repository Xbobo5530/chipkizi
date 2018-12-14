import 'package:chipkizi/models/comment.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'CommentModel:';

abstract class CommentModel extends Model {
  final Firestore _database = Firestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  StatusCode _submittingCommentStatus;
  StatusCode get submittingCommentStatus => _submittingCommentStatus;

  CollectionReference _commentsColRef(Recording recording) => _database
      .collection(RECORDINGS_COLLECTION)
      .document(recording.id)
      .collection(COMMENTS_COLLECTION);

  Stream<QuerySnapshot> commentsStream(Recording recording, SourcePage source) {
    switch (source) {
      case SourcePage.player:
        return _commentsColRef(recording)
            .orderBy(CREATED_AT_FIELD, descending: true)
            .limit(10)
            .snapshots();
        break;
      case SourcePage.comments:
        return _commentsColRef(recording)
            .orderBy(CREATED_AT_FIELD, descending: true)
            .snapshots();
        break;
      default:
        return _commentsColRef(recording)
            .orderBy(CREATED_AT_FIELD, descending: true)
            .limit(10)
            .snapshots();
    }
  }

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
    DocumentReference docRef = await _database
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
    _firebaseMessaging.subscribeToTopic(comment.recordingId);
    _createNotificationDoc(docRef);
    notifyListeners();
    return _submittingCommentStatus;
  }

  DocumentReference _commentDocRef(Comment comment) => _database
      .collection(RECORDINGS_COLLECTION)
      .document(comment.recordingId)
      .collection(COMMENTS_COLLECTION)
      .document(comment.id);

  Future<StatusCode> editComment(Comment comment) async {
    print('$_tag at editComment');
    _submittingCommentStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    Map<String, dynamic> updateMap = {
      MESSAGE_FIELD: comment.message,
      IS_MODIFIED_FIELD: VAL_IS_MODIFIED
    };
    await _commentDocRef(comment).updateData(updateMap).catchError((error) {
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

  DocumentReference _userDocRef(String userId) =>
      _database.collection(USERS_COLLECTION).document(userId);

  Future<User> _userFromId(String userId) async {
    bool _hasError = false;
    DocumentSnapshot document =
        await _userDocRef(userId).get().catchError((error) {
      print('$_tag error on getting user doc $error');
      _hasError = true;
    });
    if (_hasError || !document.exists) return null;
    return User.fromSnapshot(document);
  }

  Future<Comment> refineComment(Comment comment) async {
    print('$_tag at refineComment');
    User user = await _userFromId(comment.createdBy);
    if (user == null) return comment;
    comment.username = user.name;
    comment.userImageUrl = user.imageUrl;
    return comment;
  }

  Future<Comment> _commentFromDocRef(DocumentReference ref) async {
    bool _hasError = false;
    DocumentSnapshot document = await ref.get().catchError((error) {
      print('$_tag error on getting new comment doc:  $error');
      _hasError = true;
    });
    if (_hasError) return null;
    return Comment.fromSnapshot(document);
  }

  Future<void> _createNotificationDoc(DocumentReference docRef) async {
    print('$_tag at _createNotificationDoc');
    Comment comment = await _commentFromDocRef(docRef);
    Comment refinedComment = await refineComment(comment);
    final username =
        refinedComment.username != null ? refinedComment.username : APP_NAME;
    Map<String, dynamic> notificationMap = {
      TITLE_FIELD: newCommentText,
      BODY_FIELD:
          '${refinedComment.message}\n$username\n${refinedComment.message}',
      ID_FIELD: refinedComment.id,
      FIELD_NOTIFICATION_TYPE: FIELD_NOTIFICATION_TYPE_NEW_COMMENT,
    };
    _database
        .collection(MESSAGES_COLLECTION)
        .add(notificationMap)
        .catchError((error) {
      print('$_tag error on creating notication doc');
    });
  }
}
