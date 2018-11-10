import 'package:chipkizi/values/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recording {
  String id, title, description, createdBy, imageUrl, recordingUrl;
  int upotes, playCount, createdAt;

  Recording(
      {this.id,
      this.title,
      this.description,
      this.createdBy,
      this.imageUrl,
      this.recordingUrl,
      this.upotes,
      this.playCount,
      this.createdAt});

  Recording.fromSnaspshot(DocumentSnapshot document)
      : this.id = document.documentID,
        this.title = document[TITLE_FIELD],
        this.description = document[DESCRIPTION_FIELD],
        this.createdBy = document[CREATED_BY_FIELD],
        this.imageUrl = document[IMAGE_URL_FIELD],
        this.recordingUrl = document[RECORDING_URL_FIELD],
        this.upotes = document[UPVOTE_COUNT_FIELD],
        this.playCount = document[PLAY_COUNT_FIELD],
        this.createdAt = document[CREATED_AT_FIELD];
}
