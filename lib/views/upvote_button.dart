import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'UpvoteButtonView:';

class UpvoteButtonView extends StatelessWidget {
  final Recording recording;

  const UpvoteButtonView({Key key, @required this.recording})
      : assert(recording != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    _handleUpvote(BuildContext context, MainModel model) async {
      StatusCode upvoteStatus =
          await model.hanldeUpvoteRecording(recording, model.currentUser);
      switch (upvoteStatus) {
        case StatusCode.failed:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
          ));
          break;
        default:
          print('$_tag upvote status is: $upvoteStatus');
      }
    }

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return FutureBuilder<bool>(
          initialData: false,
          future: model.hasUpvoted(recording, model.currentUser),
          builder: (context, snapshot) {
            bool hasUpvoted = snapshot.data;
            return CircularIconButton(
              button: IconButton(
                icon: hasUpvoted
                    ? Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                    : Icon(Icons.favorite_border),
                onPressed: model.isLoggedIn ? () => _handleUpvote(context, model)
                : ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginPage(),
                fullscreenDialog: true)),
              ),
              color: Colors.white,
            );
          },
        );
      },
    );
  }
}
