import 'dart:io';

import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/user_recordings.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/my_profile_image_section.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'MyProfilePage:';

class MyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _nameFieldController = TextEditingController();
    final _bioFieldController = TextEditingController();

    

    Future<void> _handleEdit(MainModel model, DetailType type) async {
      User _userWithNewDetails = model.currentUser;
      final name = _nameFieldController.text.trim();
      final bio = _bioFieldController.text.trim();
      print(type);
      switch (type) {
        case DetailType.name:
          if (name.isNotEmpty) _userWithNewDetails.name = name;
          break;
        case DetailType.bio:
          if (bio.isNotEmpty) _userWithNewDetails.bio = bio;
          break;
        default:
          print('$_tag unexpected type: $type');
      }

      StatusCode status =
          await model.editAccountDetails(_userWithNewDetails, type);
      if (status == StatusCode.failed)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
    }

    _showEditDialog(MainModel model, DetailType type) async {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(type == DetailType.name ? nameText : bioText),
              content: TextField(
                maxLines: type == DetailType.name ? 1 : null,
                textCapitalization: type == DetailType.name
                    ? TextCapitalization.words
                    : TextCapitalization.sentences,
                cursorColor: Colors.brown,
                controller: type == DetailType.name
                    ? _nameFieldController
                    : _bioFieldController,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: type == DetailType.name
                        ? model.currentUser.name
                        : model.currentUser.bio != null &&
                                model.currentUser.bio.isNotEmpty
                            ? model.currentUser.bio
                            : bioText),
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.grey,
                  child: Text(cancelText),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: Text(submitText),
                  onPressed: () {
                    _handleEdit(
                        model,
                        type == DetailType.name
                            ? DetailType.name
                            : DetailType.bio);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }



    Widget _buildInfoSection(MainModel model) => ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.person,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: Text(model.currentUser.name),
            ),
            IconButton(
                icon: Icon(Icons.edit),
                color: Colors.black12,
                onPressed: () => _showEditDialog(model, DetailType.name))
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.description,
                color: Colors.grey,
              ),
            ),
            Expanded(
                child: model.currentUser.bio != null
                    ? Text(model.currentUser.bio)
                    : Text(
                        bioText,
                        style: TextStyle(color: Colors.black12),
                      )),
            IconButton(
              icon: Icon(Icons.edit),
              color: Colors.black12,
              onPressed: () => _showEditDialog(model, DetailType.bio),
            )
          ],
        ));

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
          child: ListView(
            children: <Widget>[
              MyProfileImageSection(),
              _buildInfoSection(model),
              Divider(),
              _buildRecordingsSection(
                  model, myRecordingsText, ListType.userRecordings, Icons.mic),
              _buildRecordingsSection(
                  model, bookmarksText, ListType.bookmarks, Icons.bookmark),
              _buildRecordingsSection(
                  model, favoritesText, ListType.upvotes, Icons.favorite)
            ],
          ),
        );
      },
    );
  }
}
