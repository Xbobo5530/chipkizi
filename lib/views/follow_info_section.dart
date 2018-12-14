import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/follow_page.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class FollowInfoSection extends StatelessWidget {
  final User user;

  const FollowInfoSection({Key key,@required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _getFollowTitle(FollowItem item) {
      switch (item) {
        case FollowItem.followers:
          return followersText;
          break;
        case FollowItem.following:
          return followingText;
          break;
        default:
          return '';
      }
    }

    _buildFollowTile(MainModel model, FollowItem item) => Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
        child: ListTile(
          onTap: ()=>Navigator.push(context, MaterialPageRoute(
            builder: (_)=>FollowPage(user: user, followItem: item),fullscreenDialog: true
          )),
          title: Text(
            _getFollowTitle(item),
            textAlign: TextAlign.center,
          ),
          subtitle: FutureBuilder<int>(
              initialData: 0,
              future: model.followCount(user, item),
              builder: (context, snapshot) => Text(
                    snapshot.data.toString(),
                    textAlign: TextAlign.center,
                  )),
        ));
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildFollowTile(model, FollowItem.followers),
              _buildFollowTile(model, FollowItem.following),
            ],
          ),
    );
  }
}
