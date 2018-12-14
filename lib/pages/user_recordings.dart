import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/empty_view.dart';
import 'package:chipkizi/views/recordings_list_item.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'UserRecordingsPage:';

class UserRecordingsPage extends StatelessWidget {
  final User user;
  final ListType type;

  const UserRecordingsPage({Key key, this.user, this.type}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String _getTitle() {
      switch (type) {
        case ListType.userRecordings:
          return myRecordingsText;
          break;
        case ListType.bookmarks:
          return bookmarkText;
          break;
        case ListType.upvotes:
          return favoritesText;
          break;
        default:
          return APP_NAME;
      }
    }

    AppBar _buildAppBar(MainModel model, AsyncSnapshot snapshot) => AppBar(
          elevation: (snapshot.hasData && snapshot.data.length == 0) ? 0 : 4,
          title: Text(_getTitle()),
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        );

    _buildEditableListItem(
            MainModel model, List<Recording> recordings, Recording recording) =>
        Dismissible(
            key: Key(recording.id),
            onDismissed: (_) {
              recordings.remove(recording);
              switch (type) {
                case ListType.userRecordings:
                  model.deleteRecording(recording, model.currentUser);
                  break;
                case ListType.bookmarks:
                  model.handleBookbarkRecording(recording, model.currentUser);
                  break;
                case ListType.upvotes:
                  model.removeFavorite(recording, user);
                  break;
              }
            },
            child: RecordingsListItemView(
              key: Key(recording.id),
              recording: recording,
              type: type,
              recordings: recordings,
            ));

    Widget _buildBody(MainModel model) => FutureBuilder<List<Recording>>(
          future: model.getUserRecordings(user, type),
          builder: (_, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            List<Recording> recordings = snapshot.data;
            return ListView(
                children: recordings
                    .map((recording) => recording != null
                        ? user.id == model.currentUser.id
                            ? _buildEditableListItem(
                                model, recordings, recording)
                            : RecordingsListItemView(
                                key: Key(recording.id),
                                recording: recording,
                                type: type,
                                recordings: recordings,
                              )
                        : Container())
                    .toList());
          },
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return FutureBuilder<List<Recording>>(
          future: model.getUserRecordings(user, type),
          builder: (context, snapshot) => Scaffold(
              appBar: _buildAppBar(model, snapshot),
              body: !snapshot.hasData
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : snapshot.data.length == 0
                      ? EmptyView(
                          type: type,
                        )
                      : _buildBody(model)),
        );
      },
    );
  }
}
