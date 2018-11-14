import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
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

    Widget _buildUpvoteButton(MainModel model) => FutureBuilder<bool>(
          initialData: false,
          future: model.hasUpvoted(recording, model.currentUser),
          builder: (context, snapshot) {
            bool hasUpvoted = snapshot.data;
            return Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
              ),
              child: CircularIconButton(
                button: IconButton(
                  icon: hasUpvoted
                      ? Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : Icon(Icons.favorite_border),
                  onPressed: model.isLoggedIn
                      ? () => _handleUpvote(context, model)
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LoginPage(),
                              fullscreenDialog: true)),
                ),
                color: Colors.white,
              ),
            );
          },
        );

    Widget _buildCounterSection(MainModel model) => Positioned(
          bottom: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: FutureBuilder<int>(
                initialData: 0,
                future: model.getUpvoteCountFor(recording.id),
                builder: (context, snapshot) {
                  int upvoteCount = snapshot.data;
                  return model.upvotingRecordingStatus == StatusCode.waiting
                      ? MyProgressIndicator(
                          color: Colors.brown,
                          size: 8.0,
                          value: null,
                          strokeWidth: 2.0,
                          isCentered: true,
                        )
                      : Text(
                          '$upvoteCount',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.brown),
                        );
                }),
          ),
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return Stack(
          children: <Widget>[
            _buildUpvoteButton(model),
            _buildCounterSection(model),
          ],
        );
      },
    );
  }
}
