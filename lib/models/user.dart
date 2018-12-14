import 'package:chipkizi/values/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id, name, imageUrl, imagePath, bio;
  int createdAt;

  User(
      {this.bio,
      this.id,
      this.imageUrl,
      this.imagePath,
      this.createdAt,
      this.name});

  User.fromSnapshot(DocumentSnapshot document)
      : id = document.documentID,
        name = document[NAME_FIELD],
        bio = document[BIO_FIELD],
        imageUrl = document[IMAGE_URL_FIELD],
        imagePath = document[IMAGE_PATH_FIELD],
        createdAt = document[CREATED_AT_FIELD];

  @override
  String toString() => '''
  id: ${this.id},
  name: ${this.name},
  bio: ${this.bio},
  imageUrl: ${this.imageUrl},
  imagePath: ${this.imagePath},
  createdAt: ${this.createdAt},
  ''';
}
