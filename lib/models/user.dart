import 'package:chipkizi/values/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id, name, imageUrl, bio;
  int createdAt;

  User({this.bio, this.id, this.imageUrl, this.createdAt, this.name});

  User.fromSnapshot(DocumentSnapshot document): 
  id = document.documentID,
  name = document[NAME_FIELD],
  bio = document[BIO_FIELD],
  imageUrl = document[IMAGE_URL_FIELD], 
  createdAt = document[CREATED_AT_FIELD];

}