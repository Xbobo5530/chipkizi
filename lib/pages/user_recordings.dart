import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
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
    AppBar _buildAppBar(MainModel model) => AppBar(
          title: Text(
            type == ListType.userRecordings
                ? user.id == model.currentUser.id
                    ? myRecordingsText
                    : '${user.name}\'s $recordingsText'
                : bookmarksText,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        );

    Widget _buildBody(MainModel model) => FutureBuilder<List<Recording>>(
          future: model.getUserRecordings(user, type),
          builder: (_, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            List<Recording> recordings = snapshot.data;
            print('$_tag list has ${recordings.length} recordings');
            return ListView(
                children: recordings
                    .map((recording) => RecordingsListItemView(
                          recording: recording,
                          type: type,
                          recordings: recordings,
                        ))
                    .toList());
          },
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return Scaffold(
          appBar: _buildAppBar(model),
          body: _buildBody(model),
        );
      },
    );
  }
}
