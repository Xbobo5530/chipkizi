import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/follow_info_section.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/profile_recordings_list_section.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({Key key, @required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _appBar = AppBar(
      title: Text(APP_NAME),
    );
    _buildImageSection(user) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Hero(
                tag: TAG_MAIN_BUTTON,
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.brown,
                  backgroundImage: user.imageUrl != null
                      ? NetworkImage(user.imageUrl)
                      : AssetImage(ASSET_LAUNCHER_ICON),
                )),
          ),
        );

    _handleFollow(MainModel model, User user) async {
      if (model.isLoggedIn) {
        StatusCode followStatus =
            await model.handleFollow(model.currentUser, user);
        if (followStatus == StatusCode.failed)
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
          ));
      } else {
        model.goToLogin(context);
      }
    }

    _buildFollowButton(MainModel model, User user) =>
        model.handlingFollowStatus == StatusCode.waiting
            ? Padding(
                padding: const EdgeInsets.all(18),
                child: Center(
                    child: MyProgressIndicator(
                  color: Colors.brown,
                  value: null,
                  strokeWidth: 2,
                )))
            : FutureBuilder<bool>(
                initialData: false,
                future: model.isFollowing(model.currentUser, user),
                builder: (context, snapshot) => snapshot.data
                    ? FlatButton(
                        onPressed: () => _handleFollow(model, user),
                        child: Text(followingText),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.brown,
                          child: Text(followText),
                          onPressed: () => _handleFollow(model, user),
                        )));

    _infoSection(User user) => ListTile(
          title: Text(
            user.name != null ? user.name : APP_NAME,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          subtitle: user.bio != null
              ? Text(
                  user.bio,
                  textAlign: TextAlign.center,
                )
              : null,
        );
    // _getFollowTitle(FollowItem item) {
    //   switch (item) {
    //     case FollowItem.followers:
    //       return followersText;
    //       break;
    //     case FollowItem.following:
    //       return followingText;
    //       break;
    //     default:
    //       return '';
    //   }
    // }

    // _buildFollowTile(MainModel model, FollowItem item) => Container(
    //     constraints:
    //         BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
    //     child: ListTile(
    //       title: Text(
    //         _getFollowTitle(item),
    //         textAlign: TextAlign.center,
    //       ),
    //       subtitle: FutureBuilder<int>(
    //           initialData: 0,
    //           future: model.followCount(user, item),
    //           builder: (context, snapshot) => Text(
    //                 snapshot.data.toString(),
    //                 textAlign: TextAlign.center,
    //               )),
    //     ));
    // _buildFollowSection(MainModel model, User user) => Row(
    //       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: <Widget>[
    //         _buildFollowTile(model, FollowItem.followers),
    //         _buildFollowTile(model, FollowItem.following),
    //       ],
    //     );
    _buildBody(MainModel model, User user) => ListView(
          children: <Widget>[
            _buildImageSection(user),
            _infoSection(user),
            _buildFollowButton(model, user),
            // _buildFollowSection(model, user),
            FollowInfoSection(user: user,),
            Divider(),
            ProfileRecordingsListSection(
                type: ListType.userRecordings,
                icon: Icons.mic,
                title: '$recordingsTitleText',
                user: user),
            ProfileRecordingsListSection(
              type: ListType.upvotes,
              icon: Icons.favorite,
              title: favoritesText,
              user: user,
            ),
          ],
        );
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => FutureBuilder<User>(
            initialData: user,
            builder: (context, snapshot) => Scaffold(
                  appBar: _appBar,
                  body: _buildBody(model, snapshot.data),
                ),
          ),
    );
  }
}
