import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

abstract class FollowModel extends Model {
  Firestore _database = Firestore.instance;
  StatusCode _handlingFollowStatus;
  StatusCode get handlingFollowStatus => _handlingFollowStatus;
  DocumentReference _followerRef(User currentUser, User target) => _database
      .collection(USERS_COLLECTION)
      .document(target.id)
      .collection(COLLECTION_FOLLOWERS)
      .document(currentUser.id);

  Future<StatusCode> handleFollow(User currentUser, User target) async {
    _handlingFollowStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    DocumentSnapshot document =
        await _followerRef(currentUser, target).get().catchError((error) {
      print('Error on getting followers list: $error');
      _hasError = true;
      _handlingFollowStatus = StatusCode.failed;
      notifyListeners();
    });

    if (_hasError) return _handlingFollowStatus;
    if (document.exists) {
      _handlingFollowStatus = await _removeFollower(currentUser, target);
      notifyListeners();
      return _handlingFollowStatus;
    }
    _handlingFollowStatus = await _addFollower(currentUser, target);
    notifyListeners();
    return _handlingFollowStatus;
  }

  Future<StatusCode> _removeFollower(User currentUser, User target) async {
    bool _hasError = false;
    _followerRef(currentUser, target).delete().catchError((error) {
      print('error on deleting follower: $error');
      _hasError = true;
      _handlingFollowStatus = StatusCode.failed;
      notifyListeners();
    });
    if (_hasError) return StatusCode.failed;
    return await _removeFollowRef(currentUser, target);
  }

  DocumentReference _followingRef(User currentUser, User target) => _database
      .collection(USERS_COLLECTION)
      .document(currentUser.id)
      .collection(COLLECTION_FOLLOWING)
      .document(target.id);

  Future<StatusCode> _removeFollowRef(User currentUser, User target) async {
    bool _hasError = false;
    _followingRef(currentUser, target).delete().catchError((error) {
      print('error on removing follow ref: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<StatusCode> _addFollower(User currentUser, User target) async {
    bool _hasError = false;
    Map<String, dynamic> followMap = {
      FIELD_FOLLOWER_ID: currentUser.id,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch,
    };
    _followerRef(currentUser, target).setData(followMap).catchError((error) {
      print('Error on adding followe');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return _createFollwerRef(currentUser, target);
  }

  Future<StatusCode> _createFollwerRef(User currentUser, User target) async {
    bool _hasError = false;
    Map<String, dynamic> followerMap = {
      FIELD_FOLLOWING_ID: target.id,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch
    };
    _followingRef(currentUser, target).setData(followerMap).catchError((error) {
      print('error on creating follower ref: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<bool> isFollowing(User currentUser, User target) async {
    print(target.toString());
    // print('the current user is: \n${currentUser.toString()}');
    if (currentUser == null) return false;
    bool _hasError = false;
    DocumentSnapshot document =
        await _followingRef(currentUser, target).get().catchError((error) {
      print('error on getting following ref: $error');
      _hasError = true;
    });
    if (_hasError) return false;
    return document.exists;
  }

  _getCollection(FollowItem item) {
    switch (item) {
      case FollowItem.followers:
        return COLLECTION_FOLLOWERS;

        break;
      case FollowItem.following:
        return COLLECTION_FOLLOWING;
        break;
    }
  }

  Future<int> followCount(User user, FollowItem item) async {
    bool _hasError = false;
    QuerySnapshot snapshot = await _database
        .collection(USERS_COLLECTION)
        .document(user.id)
        .collection(_getCollection(item))
        .getDocuments()
        .catchError((error) {
      print('error on getting follow count: $error');
      _hasError = true;
    });
    if (_hasError) return 0;
    return snapshot.documents.length;
  }
}
