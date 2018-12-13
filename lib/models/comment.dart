import 'package:chipkizi/values/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id, message, createdBy, username, userImageUrl, recordingId;
  int createdAt, isModified;

  Comment(
      {this.id,
      this.message,
      this.createdBy,
      this.username,
      this.userImageUrl,
      this.recordingId,
      this.createdAt,
      this.isModified});

  Comment.fromSnapshot(DocumentSnapshot document)
      : this.id = document.documentID,
        this.message = document[MESSAGE_FIELD],
        this.createdBy = document[CREATED_BY_FIELD],
        this.recordingId = document[RECORDING_ID_FIELD],
        this.createdAt = document[CREATED_AT_FIELD],
        this.isModified = document[IS_MODIFIED_FIELD];

  @override
  String toString() => '''
  id: ${this.id},
  message: ${this.message},
  createdBy: ${this.createdBy},
  username: ${this.username},
  userImageUrl: ${this.userImageUrl},
  recordingId: ${this.recordingId},
  createdAt: ${this.createdAt},
  isModifiet: ${this.isModified}
  ''';
}
