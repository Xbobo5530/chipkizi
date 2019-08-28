import 'package:chipkizi/models/comment.dart';
import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/add_comment_button.dart';
import 'package:chipkizi/views/comment_item_view.dart';
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
    final _commentsSection = Expanded(
        child: ScopedModelDescendant<MainModel>(
            builder: (context, child, model) => StreamBuilder<QuerySnapshot>(
                  stream: model.commentsStream(recording, SourcePage.comments),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        Comment comment = Comment.fromSnapshot(
                            snapshot.data.documents[index]);

                        return FutureBuilder<Comment>(
                          initialData: comment,
                          future: model.refineComment(comment),
                          builder: (context, snapshot) {
                            final refinedComment = snapshot.data;

                            return CommentItemView(
                              comment: refinedComment,
                              titleColor: Colors.white,
                              subTitleColor: Colors.white70,
                              avatarRadius: 20,
                            );
                          },
                        );
                      },
                    );
                  },
                )));

    final _actionSection = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        AddCommentButton(
          recording: recording,
          color: Colors.white,
          key: Key(recording.id),
        )
      ],
    );

    final _body = Column(
      children: <Widget>[_commentsSection, _actionSection],
    );

    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: _appBar,
      body: _body,
    );
  }
}
