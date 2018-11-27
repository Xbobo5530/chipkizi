import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/pages/create_recording.dart';
import 'package:chipkizi/pages/searrch_delegate.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/progress_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class EmptyView extends StatelessWidget {
  final ListType type;

  const EmptyView({Key key, this.type}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _goToPlayer(MainModel model) {
      showSearch(
          context: context,
          delegate: RecordingsSearch(recordings: model.recordings));
    }

    _goToCreateRecording() {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => RecordingPage()));
    }

    final _roundButtonSection = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Hero(
        tag: TAG_MAIN_BUTTON,
        child: ProgressButton(
          button: Icon(
            Icons.announcement,
            size: 80.0,
            color: Colors.orange,
          ),
          color: Colors.white,
          size: 150.0,
          indicator: Container(),
        ),
      ),
    );

    String _getText() {
      switch (type) {
        case ListType.userRecordings:
          return newRecordingText;
          break;
        case ListType.bookmarks:
        case ListType.upvotes:
          return browseRecordingsText;
          break;
        default:
          return browseRecordingsText;
      }
    }

    _handleSecondaryAction(MainModel model) {
      switch (type) {
        case ListType.userRecordings:
          _goToCreateRecording();
          break;
        case ListType.bookmarks:
        case ListType.upvotes:
          _goToPlayer(model);
          break;
        default:
          _goToPlayer(model);
      }
    }

    final _secondaryButton = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return RaisedButton(
            color: Colors.white,
            textColor: Colors.brown,
            child: Text(_getText()),
            onPressed: () {
              _handleSecondaryAction(model);
            });
      },
    );

    final _primaryButton = RaisedButton(
      color: Colors.white,
      textColor: Colors.brown,
      child: Text(goHomeText),
      onPressed: () {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      },
    );

    final _actions = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        _primaryButton,
        _secondaryButton,
      ],
    );

    final _textSection = Text(
      type == ListType.bookmarks ? noBookmarksText : noRecordingsText,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic),
    );

    final _body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[_roundButtonSection, _textSection, _actions],
      ),
    );

    return Scaffold(backgroundColor: Colors.brown, body: _body);
  }
}
