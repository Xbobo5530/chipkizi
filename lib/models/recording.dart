import 'package:chipkizi/values/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recording {
  String id,
      title,
      description,
      createdBy,
      username,
      userImageUrl,
      imageUrl,
      recordingUrl,
      recordingPath;
  int upvoteCount, playCount, createdAt;
  List<dynamic> genre;

  Recording(
      {this.id,
      this.title,
      this.description,
      this.createdBy,
      this.username,
      this.userImageUrl,
      this.imageUrl,
      this.recordingPath,
      this.recordingUrl,
      this.upvoteCount,
      this.playCount,
      this.genre,
      this.createdAt});

  Recording.fromSnaspshot(DocumentSnapshot document)
      : this.id = document.documentID,
        this.title = document[TITLE_FIELD],
        this.description = document[DESCRIPTION_FIELD],
        this.createdBy = document[CREATED_BY_FIELD],
        this.imageUrl = document[IMAGE_URL_FIELD],
        this.recordingUrl = document[RECORDING_URL_FIELD],
        this.recordingPath = document[RECORDING_PATH_FIELD],
        this.upvoteCount = document[UPVOTE_COUNT_FIELD],
        this.playCount = document[PLAY_COUNT_FIELD],
        this.genre = document[GENRE_FIELD],
        this.createdAt = document[CREATED_AT_FIELD];
}
