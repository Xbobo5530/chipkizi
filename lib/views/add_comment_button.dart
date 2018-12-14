import 'package:chipkizi/models/comment.dart';
import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AddCommentButton extends StatelessWidget {
  final Recording recording;
  final Color color;

  const AddCommentButton({Key key, @required this.recording, this.color})
      : assert(recording != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    final _commentConttoller = TextEditingController();

    Future<bool> _getUserInput() => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(addCommentText),
              content: TextField(
                controller: _commentConttoller,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                maxLines: null,
                decoration: InputDecoration(hintText: enterCommentText),
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.grey,
                  child: Text(cancelText),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text(submitText),
                  onPressed: () {
                    final message = _commentConttoller.text.trim();
                    if (message.isNotEmpty) Navigator.pop(context, true);
                  },
                )
              ],
            ));
    _handleAddComment(MainModel model) async {
      bool _hasSubmittedComment = await _getUserInput();
      if (!_hasSubmittedComment) return null;
      final message = _commentConttoller.text.trim();
      Comment _comment = Comment(
          message: message,
          createdBy: model.currentUser.id,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          recordingId: recording.id);
      StatusCode submitStatus = await model.submitComment(_comment);
      if (submitStatus == StatusCode.failed)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
    }

    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => FlatButton(
            textColor: color,
            child: Text(addCommentText),
            onPressed: model.isLoggedIn
                ? () => _handleAddComment(model)
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LoginPage(), fullscreenDialog: true)),
          ),
    );
  }
}
