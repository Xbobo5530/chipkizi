import 'package:chipkizi/models/comment.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/user_profile_page.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:flutter/material.dart';

class CommentItemView extends StatelessWidget {
  final Comment comment;
  final double avatarRadius;
  final Color titleColor;
  final Color subTitleColor;

  const CommentItemView(
      {Key key,
      @required this.comment,
      this.avatarRadius = 16,
      this.titleColor = Colors.black,
      this.subTitleColor = Colors.black45})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfilePage(
                    user: User(
                        id: comment.createdBy,
                        name: comment.username,
                        imageUrl: comment.userImageUrl),
                    key: Key(comment.createdBy),
                  ),
              fullscreenDialog: true)),
      leading: CircleAvatar(
        backgroundImage: comment.userImageUrl != null
            ? NetworkImage(comment.userImageUrl)
            : AssetImage(ASSET_APP_ICON),
      ),
      title: Text(
        comment.message,
        style: TextStyle(
          color: titleColor,
        ),
      ),
      subtitle: comment.username != null
          ? Text(comment.username,
              style: TextStyle(
                color: subTitleColor,
              ))
          : null,
    );
  }
}
