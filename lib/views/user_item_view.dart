import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/user_profile_page.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:flutter/material.dart';

class UserItemView extends StatelessWidget {
  final User user;

  const UserItemView({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserProfilePage(user: user, key: Key(user.id)),
              fullscreenDialog: true)),
      leading: CircleAvatar(
        backgroundColor: Colors.brown,
        backgroundImage: user.imageUrl != null
            ? NetworkImage(user.imageUrl)
            : AssetImage(ASSET_APP_ICON),
      ),
      title: Text(
        user.name,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: user.bio != null
          ? Text(
              user.bio,
              style: TextStyle(color: Colors.white70),
            )
          : null,
    );
  }
}
