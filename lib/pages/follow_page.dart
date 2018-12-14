import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/user_item_view.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class FollowPage extends StatelessWidget {
  final User user;
  final FollowItem followItem;

  const FollowPage({Key key, @required this.user, @required this.followItem})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    _getTitle() {
      switch (followItem) {
        case FollowItem.followers:
          return followersText;
          break;
        case FollowItem.following:
          return followingText;
          break;
        default:
          return APP_NAME;
      }
    }

    final _appBar = AppBar(
      elevation: 0,
      title: Hero(
        tag: TAG_MAIN_BUTTON,
        flightShuttleBuilder: (context, animation, direction, _, __) => Icon(
                Icons.fiber_manual_record,
                color: Colors.white,
              ),
        child: Text(_getTitle())),
    );
    final _body = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) => FutureBuilder<List<User>>(
          future: model.userFollowList(user, followItem),
          builder: (context, snapshot) => !snapshot.hasData
              ? Center(child:MyProgressIndicator(
                size: 40,
                strokeWidth: 4,
                value: null,))
              : ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => UserItemView(
                      user: snapshot.data[index],
                      key: Key(snapshot.data[index].id)))),
    );
    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: _appBar,
      body: _body,
    );
  }
}
