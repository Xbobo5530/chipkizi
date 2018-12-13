import 'package:chipkizi/models/comment.dart';
import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CommentsPage extends StatelessWidget {
  final Recording recording;

  const CommentsPage({Key key, this.recording}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _appBar = AppBar(
      elevation: 0,
      title: Hero(
          tag: TAG_MAIN_BUTTON,
          flightShuttleBuilder: (context, animation, direction, _, __) => Icon(
                Icons.fiber_manual_record,
                color: Colors.white,
              ),
          child: Text(commentsText)),
    );
    final _body = ScopedModelDescendant<MainModel>(
        builder: (context, child, model) => StreamBuilder<QuerySnapshot>(
              stream: model.commentsStream(recording),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    Comment comment =
                        Comment.fromSnapshot(snapshot.data.documents[index]);
                    // print(comment.toString());
                    return FutureBuilder<Comment>(
                      initialData: comment,
                      future: model.refineComment(comment),
                      builder: (context, snapshot) {
                        final refinedComment = snapshot.data;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: refinedComment.userImageUrl != null
                                ? NetworkImage(refinedComment.userImageUrl)
                                : AssetImage(ASSET_APP_ICON),
                          ),
                          title: Text(refinedComment.message),
                          subtitle: refinedComment.username != null
                              ? Text(refinedComment.username)
                              : null,
                        );
                      },
                    );
                  },
                );
              },
            ));

    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: _appBar,
      body: _body,
    );
  }
}
