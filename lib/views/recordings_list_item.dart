import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:flutter/material.dart';

class RecordingsListItemView extends StatelessWidget {
  final Recording recording;
  final MainModel model;

  const RecordingsListItemView({Key key, this.recording, this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder<User>(
        future: model.userFromId(recording.createdBy),
        builder: (context, snapshot){
          if (!snapshot.hasData) return Icon(Icons.music_note);
          User user = snapshot.data;
          return CircleAvatar(backgroundColor: Colors.black12, backgroundImage: NetworkImage(user.imageUrl),);
      },),
        title: Text(recording.title),
        isThreeLine: true,
        
        subtitle: Text(recording.description),
        trailing: PopupMenuButton(child: Icon(Icons.more_vert), itemBuilder: (BuildContext context) {},)
        );
  }
}
