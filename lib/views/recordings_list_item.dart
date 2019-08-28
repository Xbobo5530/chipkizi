import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/pages/player.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/views/genre_chip.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingsListItemView extends StatelessWidget {
  final Recording recording;
  final ListType type;
  final List<Recording> recordings;

  const RecordingsListItemView(
      {Key key, @required this.recording, this.type, this.recordings})
      : assert(recording != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final _leadingSeciton = recording.userImageUrl == null
        ? CircleAvatar(
            radius: 24.0,
            backgroundColor: Colors.brown,
            backgroundImage: AssetImage(ASSET_LAUNCHER_ICON))
        : CircleAvatar(
            radius: 24.0,
            backgroundColor: Colors.black12,
            backgroundImage: NetworkImage(recording.userImageUrl),
          );

    Widget _buildChips(Icon icon, String label) => Container(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: <Widget>[
                icon,
                Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        );

    final _playLikeSection =
        recording.playCount == 0 && recording.upvoteCount == 0
            ? Container()
            : Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.all(Radius.circular(2.0))),
                child: Row(
                  children: <Widget>[
                    recording.playCount == 0
                        ? Container()
                        : _buildChips(
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 14.0,
                            ),
                            '${recording.playCount}'),
                    recording.upvoteCount == 0
                        ? Container()
                        : _buildChips(
                            Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 14.0,
                            ),
                            '${recording.upvoteCount}')
                  ],
                ),
              );

    final _subtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            recording.description,
            maxLines: 5,
          ),
        ),
        recording.genre.length == 0
            ? Container()
            : Container(
                height: 30.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: recording.genre
                      .map((genre) => GenreChipView(genre: genre))
                      .toList(),
                ),
              )
      ],
    );

    final _titleSection = Padding(
      padding: const EdgeInsets.only(
        bottom: 4.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Text(recording.title)),
          _playLikeSection
        ],
      ),
    );

    _openRecording(List<Recording> recordings) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PlayerPage(
                  recording: recording,
                  recordings: recordings,
                  key: Key(recording.id),
                ),
            fullscreenDialog: true) //_handlePlayRecording(),
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        List<Recording> _recordings = <Recording>[];
        switch (type) {
          case ListType.bookmarks:
          case ListType.userRecordings:
            _recordings = model.arrangeRecordings(recording, recordings);
            break;
          default:
            _recordings = model.getAllRecordings(recording);
        }

        return Column(
          children: <Widget>[
            ListTile(
              leading: _leadingSeciton,
              title: _titleSection,
              subtitle: _subtitle,
              onTap: () => _openRecording(_recordings),
            ),
            Divider()
          ],
        );
      },
    );
  }
}
