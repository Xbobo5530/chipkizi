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

  User _currentUser;
  User get currentUser => _currentUser;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  StatusCode _loginInStatus;
  StatusCode get loginStatus => _loginInStatus;
  StatusCode _updatingLoginStatus;
  StatusCode get updatingLoginStatus => _updatingLoginStatus;

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
}
