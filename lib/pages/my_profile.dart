import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/pages/user_recordings.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recordings_list.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildImageSection(String imageUrl) => imageUrl != null
        ? CircleAvatar(
            radius: 60.0,
            backgroundColor: Colors.brown,
            backgroundImage: NetworkImage(imageUrl),
          )
        : Icon(Icons.account_circle);

    //todo make this section inline editable...
    Widget _buildInfoSection(MainModel model) => ListTile(
          title: Text(model.currentUser.name),
          subtitle: model.currentUser.bio != null
              ? Text(model.currentUser.bio)
              : Container(),
        );

    Widget _buildRecordingsSection(
            MainModel model, String title, ListType type, IconData icon) =>
        ListTile(
          title: Text(title),
          leading: Icon(icon),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      UserRecordingsPage(user: model.currentUser, type: type),
                  fullscreenDialog: true)),
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: <Widget>[
              _buildImageSection(model.currentUser.imageUrl),
              _buildInfoSection(model),
              _buildRecordingsSection(
                  model, myRecordingsText, ListType.userRecordings, Icons.mic),
              _buildRecordingsSection(
                  model, bookmarksText, ListType.bookmarks, Icons.bookmark)
            ],
          ),
        );
      },
    );
  }
}
