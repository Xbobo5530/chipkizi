import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'BookmarkButtonView:';
class BookmarkButtonView extends StatelessWidget {
  final Recording recording;

  const BookmarkButtonView({Key key, @required this.recording})
      : assert(recording != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    _handleBookmark(BuildContext context, MainModel model) async {
      StatusCode bookmarkStatus =
          await model.handleBookbarkRecording(recording, model.currentUser);
      switch (bookmarkStatus) {
        case StatusCode.failed:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
          ));
          break;
        default:
          print('$_tag bookmark status is $bookmarkStatus');
      }
    }

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return FutureBuilder<bool>(
          future: model.hasBookmarked(recording, model.currentUser),
          initialData: false,
          builder: (context, snapshot) {
            bool hasBookmarked = snapshot.data;
            return CircularIconButton(
              button: IconButton(
                icon: hasBookmarked
                    ? Icon(
                        Icons.bookmark,
                        color: Colors.orange,
                      )
                    : Icon(
                        Icons.bookmark_border,
                      ),
                onPressed: model.isLoggedIn
                    ? () => _handleBookmark(context, model)
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoginPage(),
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
