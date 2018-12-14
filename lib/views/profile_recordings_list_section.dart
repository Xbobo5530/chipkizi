import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/user_recordings.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileRecordingsListSection extends StatelessWidget {
  final String title;
  final ListType type;
  final IconData icon;
  final User user;

  const ProfileRecordingsListSection(
      {Key key, @required this.title, @required this.type, @required this.icon,@required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => ListTile(
            title: Text(title),
            leading: Icon(icon),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        UserRecordingsPage(user: user, type: type),
                    fullscreenDialog: true)),
          ),
    );
  }
}
