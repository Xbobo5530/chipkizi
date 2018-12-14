import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class MessagingModel extends Model {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  void firebaseCloudMessagingListeners() {
    // if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      // print(token);
    });

    _firebaseMessaging.subscribeToTopic(SUBSCRIPTION_UPDATES);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  subscribeToPrivate(User user) {
    _firebaseMessaging.subscribeToTopic('private_${user.id}');
  }
}
