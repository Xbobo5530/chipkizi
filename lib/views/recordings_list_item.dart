import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/login.dart';

import 'package:chipkizi/pages/player.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'RecordingsListItemView:';

class RecordingsListItemView extends StatelessWidget {
  final Recording recording;

  const RecordingsListItemView({Key key, this.recording}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _goToLogin() => Navigator.push(context,
        MaterialPageRoute(builder: (_) => LoginPage(), fullscreenDialog: true));
    _handleAction(
        BuildContext context, MainModel model, RecordingActions action) {
      switch (action) {
        case RecordingActions.upvote:
          model.isLoggedIn
              ? model.hanldeUpvoteRecording(recording, model.currentUser)
              : _goToLogin();
          break;
        case RecordingActions.bookmark:
          model.isLoggedIn
              ? model.handleBookbarkRecording(recording, model.currentUser)
              : _goToLogin();
          break;
        default:
          print('$_tag the popup menu selected acion is: $action');
      }
    }

    final _leadingSection =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return FutureBuilder<User>(
        future: model.userFromId(recording.createdBy),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Icon(Icons.mic);
          User user = snapshot.data;
          return CircleAvatar(
            backgroundColor: Colors.black12,
            backgroundImage: NetworkImage(user.imageUrl),
          );
        },
      );
    });

    final _popUpMenu = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return PopupMenuButton<RecordingActions>(
          onSelected: (action) => _handleAction(context, model, action),
          child: Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem<RecordingActions>>[
              // PopupMenuItem( child: Text(upvoteText),),
              PopupMenuItem(
                value: RecordingActions.upvote,
                child: Text(upvoteText),
              ),
              PopupMenuItem(
                value: RecordingActions.share,
                child: Text(shareText),
              ),
              PopupMenuItem(
                value: RecordingActions.bookmark,
                child: Text(bookmarkText),
              ),
            ];
          },
        );
      },
    );

    return ListTile(
        leading: _leadingSection,
        title: Text(recording.title),
        isThreeLine: true,
        subtitle: Text(recording.description),
        trailing: _popUpMenu,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PlayerPage(recording: recording),
                fullscreenDialog: true)) //_handlePlayRecording(),
        );
  }
}

// enum RecordingActions { share, open, bookmark, upvote }

