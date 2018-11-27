import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'AccountModel:';

abstract class AccountModel extends Model {
  final Firestore _database = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Map<String, User> _cachedUsers = Map();
  User _currentUser;
  User get currentUser => _currentUser;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  StatusCode _loginInStatus;
  StatusCode get loginStatus => _loginInStatus;
  StatusCode _updatingLoginStatus;
  StatusCode get updatingLoginStatus => _updatingLoginStatus;
  StatusCode _editingUserDetailsStatus;
  StatusCode get editingUserDetailsStatus => _editingUserDetailsStatus;
  bool _isEditingUsername = false;
  bool get isEditingName => _isEditingUsername;
  bool _isEditingUserBio = false;
  bool get isEditingDesc => _isEditingUserBio;

  Future<StatusCode> updateLoginStatus() async {
    print('$_tag at updateLoginStatus');
    _updatingLoginStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    final user = await _auth.currentUser().catchError((error) {
      print('$_tag error on getting current user: $error');
      _hasError = true;
    });
    if (_hasError) {
      _updatingLoginStatus = StatusCode.failed;
      notifyListeners();
      return _updatingLoginStatus;
    }
    if (user == null) {
      _updatingLoginStatus = StatusCode.success;
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
      return _updatingLoginStatus;
    }
    DocumentSnapshot document = await _database
        .collection(USERS_COLLECTION)
        .document(user.uid)
        .get()
        .catchError((error) {
      print('$_tag updating login status: $error');
      _hasError = true;
    });

    if (_hasError || !document.exists) {
      _updatingLoginStatus = StatusCode.failed;
      notifyListeners();
      return _updatingLoginStatus;
    }

    User currentUser = User.fromSnapshot(document);
    _currentUser = currentUser;
    _isLoggedIn = true;
    _updatingLoginStatus = StatusCode.success;
    notifyListeners();
    return _updatingLoginStatus;
  }

  Future<StatusCode> loginWithGoogle() async {
    print('$_tag at loginWithGoogle');
    _loginInStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    final GoogleSignInAccount googleUser =
        await _googleSignIn.signIn().catchError((error) {
      print('$_tag error on signing in: $error');
      _hasError = true;
    });
    if (_hasError) {
      _loginInStatus = StatusCode.failed;
      notifyListeners();
      return _loginInStatus;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth
        .signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    )
        .catchError((error) {
      print('$_tag error on signing in with firebase: $error');
      _hasError = true;
    });
    if (_hasError) {
      _loginInStatus = StatusCode.failed;
      notifyListeners();
      return _loginInStatus;
    }
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    if (user == null) {
      _loginInStatus = StatusCode.failed;
      notifyListeners();
      return _loginInStatus;
    }

    _loginInStatus = await _checkIfUserExists(user);
    notifyListeners();
    updateLoginStatus();
    return _loginInStatus;
  }

  Future<StatusCode> _checkIfUserExists(FirebaseUser user) async {
    print('$_tag at _checkIfUserExists');
    bool _hasError = false;
    final userId = user.uid;
    DocumentSnapshot document = await _database
        .collection(USERS_COLLECTION)
        .document(userId)
        .get()
        .catchError((error) {
      print('$_tag error on getting current user doc: $error');
      _hasError = true;
    });

    if (_hasError) return StatusCode.failed;
    if (!document.exists) return await _createUserDoc(user);
    return StatusCode.success;
  }

  Future<StatusCode> _createUserDoc(FirebaseUser user) async {
    print('$_tag at _createUserDoc');
    bool _hasError = false;
    Map<String, dynamic> userMap = {
      ID_FIELD: user.uid,
      NAME_FIELD: user.displayName,
      IMAGE_URL_FIELD: user.photoUrl,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch
    };

    await _database
        .collection(USERS_COLLECTION)
        .document(user.uid)
        .setData(userMap)
        .catchError((error) {
      print('$_tag error on getting current user doc: $error');
      _hasError = true;
    });

    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<User> userFromId(String userId) async {
    // print('$_tag at userFromId');
    bool _hasError = false;
    if (_cachedUsers[userId] != null) return _cachedUsers[userId];
    DocumentSnapshot document = await _database
        .collection(USERS_COLLECTION)
        .document(userId)
        .get()
        .catchError((error) {
      print('$_tag error on getting user document form id');
      _hasError = true;
    });
    if (_hasError) return null;
    final userFromId = User.fromSnapshot(document);
    _cachedUsers.putIfAbsent(userId, () => userFromId);
    return userFromId;
  }

  /// called when the user clicks the  edit profile icon
  /// the [type] is a [DetailType] that will be passed to indicate
  /// which field the user is updating
  /// the [type] is for the user limited to [DetailType.name] and [DetailType.bio]
  void startEditingProfile(DetailType type) {
    print('$_tag at startEditingProfile');
    switch (type) {
      case DetailType.name:
        _isEditingUsername = true;
        notifyListeners();
        break;
      case DetailType.bio:
        _isEditingUserBio = true;
        notifyListeners();
        break;
      default:
        print('$_tag unexpected type: $type');
    }
  }

  /// called to reset the is editing fields whent he user has
  /// finished editing the respective fields
  /// the [type] is a [DetailType] a function will pass
  /// to specify the field that needs reset
  /// the [type] on isEditing fields will be limited to
  /// [DetailType.name] which will reset the [_isEditingUsername] field to [false]
  /// and teh [DetailType.bio] which will reset the [_isEditingUserBio] field to [false]
  resetIsEditingField(DetailType type) {
    switch (type) {
      case DetailType.name:
        _isEditingUsername = false;
        break;
      case DetailType.bio:
        _isEditingUserBio = false;
        break;
      default:
        print('$_tag unexpected type: $type');
    }
  }

  /// EditAccountDetails is called when the user finishes entering new detail
  /// after clicking the edit profile icon
  /// the [user] is of type [User] which is the user who is editing the profile
  /// the [user] is typically the currenttly logged in user
  /// the [DetailType] [type] is the specific field that the user is currently editing
  /// the [type] for editAccountDetails is limited to [DetailType.name] and [DetailType.bio]
  Future<StatusCode> editAccountDetails(User user, DetailType type) async {
    print('$_tag at editAccountDetails');
    _editingUserDetailsStatus = StatusCode.waiting;
    bool _hasError = false;
    Map<String, dynamic> detailMap = Map();
    print(type);
    switch (type) {
      case DetailType.name:
        detailMap.putIfAbsent(NAME_FIELD, () => user.name);
        break;
      case DetailType.bio:
        detailMap.putIfAbsent(BIO_FIELD, () => user.bio);
        print('done putting ${user.bio} in $BIO_FIELD');
        break;
      case DetailType.imageUrl:
        detailMap.putIfAbsent(IMAGE_URL_FIELD, () => user.imageUrl);
        detailMap.putIfAbsent(IMAGE_PATH_FIELD, ()=>user.imagePath);
        break;
      default:
        print('$_tag unexpected detail type: $type');
    }
    print(detailMap['bio']);
    await _database
        .collection(USERS_COLLECTION)
        .document(user.id)
        .updateData(detailMap)
        .catchError((error) {
      print('$_tag error on updating user details: $error');
      _editingUserDetailsStatus = StatusCode.failed;
      _hasError = true;
      resetIsEditingField(type);
      notifyListeners();
    });
    if (_hasError) return _editingUserDetailsStatus;
    _editingUserDetailsStatus = StatusCode.success;
    resetIsEditingField(type);
    _updateCachedUserInfo(user);
    notifyListeners();
    return _editingUserDetailsStatus;
  }

  setUplaodWaitingStatus(){
    _editingUserDetailsStatus = StatusCode.waiting;
    notifyListeners();
  }

  _updateCachedUserInfo(User user) {
    print('$_tag rat _updateCachedUserInfo\nremoving cahced user');
    final userId = user.id;
    _cachedUsers.remove(userId);
  }

  Future<StatusCode> logout() async {
    print('$_tag at logout');
    bool _hasError = false;
    await _auth.signOut().catchError((error) {
      print('$_tag error on logging out: $error');
      _hasError = true;
    });
    if (_hasError) {
      updateLoginStatus();
      return StatusCode.failed;
    }
    updateLoginStatus();
    return StatusCode.success;
  }
}
