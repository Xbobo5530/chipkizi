import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/bookmark_button.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/genre_chip.dart';
import 'package:chipkizi/views/play_button.dart';
import 'package:chipkizi/views/upvote_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingCard extends StatelessWidget {
  final Recording recording;

  const RecordingCard({Key key, @required this.recording}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _buildImageSection(MainModel model) => FutureBuilder<User>(
        future: model.userFromId(recording.createdBy),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Icon(
              Icons.mic,
              size: 45.0,
            );
          final User user = snapshot.data;
          return Center(
            child: CircleAvatar(
              radius: 60.0,
              backgroundColor: Colors.black12,
              backgroundImage: NetworkImage(user.imageUrl),
            ),
          );
        });

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

          SizedBox(height: 8.0,)


          // TODO: add comments
          // ButtonBar(
          //   alignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     RaisedButton(
          //       color: Colors.white,
          //       textColor: Colors.brown,
          //       child: Text(commentsText),
          //       onPressed: () {},
          //     )
          //   ],
          // ),
        ]);
     _buildShareButton(MainModel model) => Positioned(
      top: 0.0,
      right: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(Icons.share),
          onPressed: () =>model.shareRecording(recording),
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

    _buildInfoSection(MainModel model) => FutureBuilder<User>(
          future: model.userFromId(recording.createdBy),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return Container();
            final user = snapshot.data;
            return ListTile(
                title: Text(
                  recording.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                subtitle: Text(
                  user.name,
                  textAlign: TextAlign.center,
                ));
          },
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

    _buildCardSection(MainModel model) => Card(
        color: Colors.white70,
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 40.0,
            ),
            _buildImageSection(model),
            _buildInfoSection(model),
            _buildActions(model),
            _descriptionSection,
            recording.genre != null && recording.genre.length > 0
                ? _genresSection
                : Container(),
          ],
        ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
      child: ScopedModelDescendant<MainModel>(
        builder: (_, __, model) {
          return Stack(
            children: <Widget>[
              _buildCardSection(model),
              //TODO: enabke share button
              _buildShareButton(model),
              _closeButton
            ],
          );
        },
      ),
    );
  }
}
