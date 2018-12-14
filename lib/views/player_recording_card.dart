import 'package:chipkizi/models/comment.dart';
import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/comments_page.dart';
import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/pages/user_profile_page.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/add_comment_button.dart';
import 'package:chipkizi/views/bookmark_button.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/genre_chip.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/play_button.dart';
import 'package:chipkizi/views/upvote_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingCard extends StatelessWidget {
  final Recording recording;

  const RecordingCard({Key key, @required this.recording}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final _imageSection = recording.imageUrl != null
        ? Center(
            child: CircleAvatar(
              radius: 60.0,
              backgroundColor: Colors.black12,
              backgroundImage: NetworkImage(recording.imageUrl),
            ),
          )
        : recording.userImageUrl != null
            ? Center(
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.black12,
                  backgroundImage: NetworkImage(recording.userImageUrl),
                ),
              )
            : Center(
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.black12,
                  backgroundImage: AssetImage('images/ic_launcher.png'),
                ),
              );

    _buildActions(MainModel model) => Column(children: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              BookmarkButtonView(recording: recording),
              Hero(
                tag: TAG_MAIN_BUTTON,
                child: PlayButtonView(
                  recording: recording,
                ),
              ),
              UpvoteButtonView(recording: recording),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularIconButton(
                size: 40.0,
                button: IconButton(
                  icon: Icon(
                    Icons.stop,
                    color: Colors.brown,
                  ),
                  onPressed: () => model.stop(),
                ),
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          )
        ]);
    _buildShareButton(MainModel model) => Positioned(
          top: 0.0,
          right: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.share),
              onPressed: () => model.shareRecording(recording),
            ),
          ),
        );

    final _closeButton = Positioned(
      top: 0.0,
      left: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ScopedModelDescendant<MainModel>(
          builder: (_, __, model) {
            return IconButton(
              icon: Icon(
                Icons.close,
                // color: Colors.white,
              ),
              onPressed: () {
                model.stop();
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );

    final _infoSection = ListTile(
      title: Text(
        recording.title,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      subtitle: recording.username != null
          ? ActionChip(
            avatar: CircleAvatar(
              backgroundColor: Colors.brown,
              backgroundImage: NetworkImage(recording.userImageUrl),
            ),
            label: Text(
              recording.username,
              textAlign: TextAlign.center,
            ), onPressed: ()=> Navigator.push(
              context, MaterialPageRoute(
                builder: (context)=>UserProfilePage(user: User(id: recording.createdBy, name: recording.username, imageUrl: recording.userImageUrl),),fullscreenDialog: true
              )
            ),)
          : null,
    );

    final _genresSection = ExpansionTile(
      leading: Icon(Icons.dashboard),
      title: Text(genresText),
      children: recording.genre
          .map((genre) => Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 40.0),
              child: GenreChipView(genre: genre)))
          .toList(),
    );

    final _descriptionSection = ExpansionTile(
      leading: Icon(Icons.description),
      title: Text(descriptionText),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            recording.description,
            textAlign: TextAlign.start,
          ),
        )
      ],
    );

    _buildCommentsList(MainModel model, List<DocumentSnapshot> documents) =>
        ExpansionTile(
            leading: Icon(Icons.comment),
            title: Text(commentsText),
            children: documents.map((document) {
              Comment comment = Comment.fromSnapshot(document);
              return FutureBuilder<Comment>(
                  future: model.refineComment(comment),
                  initialData: comment,
                  builder: (context, snapshot) => ListTile(
                        title: Text(comment.message),
                        leading: CircleAvatar(
                          radius: 16.0,
                          backgroundColor: Colors.brown,
                          backgroundImage: comment.userImageUrl == null
                              ? AssetImage(ASSET_LAUNCHER_ICON)
                              : NetworkImage(comment.userImageUrl),
                        ),
                      ));
            }).toList());

    

    

    _buildCommentsSection(MainModel model) => Column(children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: model.commentsStream(recording, SourcePage.player),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                    child: MyProgressIndicator(
                  value: null,
                  strokeWidth: 2.0,
                ));
              List<DocumentSnapshot> documents = snapshot.data.documents;
              if (documents.length == 0) return Container();
              return _buildCommentsList(model, documents);
            },
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
            AddCommentButton(recording: recording,color: Colors.brown, key: Key(recording.id),),
              FlatButton(
                textColor: Colors.brown,
                child: Text(viewAllCommentsText),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommentsPage(
                              recording: recording,
                              key: Key(recording.id),
                            ), fullscreenDialog: true)),
              )
            ],
          )
        ]);

    _buildCardSection(MainModel model) => Card(
        color: Colors.white70,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 40.0,
            ),
            _imageSection,
            _infoSection,
            _buildActions(model),
            _descriptionSection,
            recording.genre != null && recording.genre.length > 0
                ? _genresSection
                : Container(),
            _buildCommentsSection(model)
          ],
        ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
      child: ScopedModelDescendant<MainModel>(
        builder: (_, __, model) {
          return Stack(
            children: <Widget>[
              _buildCardSection(model),
              _buildShareButton(model),
              _closeButton
            ],
          );
        },
      ),
    );
  }
}
