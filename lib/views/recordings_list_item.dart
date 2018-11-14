import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';

import 'package:chipkizi/pages/player.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingsListItemView extends StatelessWidget {
  final Recording recording;

  const RecordingsListItemView({Key key, this.recording}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    final _popUpMenu = PopupMenuButton(
          child: Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem>[
              // PopupMenuItem( child: Text(upvoteText),),
              PopupMenuItem(value: RecordingActions.upvote, child: Text(upvoteText),),
              PopupMenuItem(value: RecordingActions.share, child: Text(shareText),),
              PopupMenuItem(value: RecordingActions.bookmark, child: Text(bookMarkText),),
            ];
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

enum RecordingActions{share, open, bookmark, upvote}
const openText = 'Open';
const shareText = 'Share';
const bookMarkText = 'Bookmark';
const upvoteText = 'Upvote';
