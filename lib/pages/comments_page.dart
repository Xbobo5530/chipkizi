import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatelessWidget {
  final Recording recording;

  const CommentsPage({Key key, this.recording}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Hero(
            tag: TAG_MAIN_BUTTON,
            flightShuttleBuilder: (context, animation, direction, _, __) =>
                Icon(Icons.fiber_manual_record, color: Colors.white,),
            child: Text(commentsText)),
      ),
    );
  }
}
