import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/details_section.dart';
import 'package:chipkizi/views/record_section.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appBar = AppBar(
      elevation: 0.0,
      title: Hero(
          tag: TAG_APP_TITLE,
          flightShuttleBuilder: (context, animation, fightDirection, _, __) {
            return Icon(
              Icons.fiber_manual_record,
              color: Colors.white,
            );
          },
          child: Text(APP_NAME)),
      actions: <Widget>[
        Hero(
          tag: TAG_NEXT_BACK_BUTTON,
          flightShuttleBuilder: (context, animation, flightDirection, _, __) {
            return Icon(
              Icons.navigate_before,
              color: Colors.white,
            );
          },
          child: ScopedModelDescendant<MainModel>(
            builder: (context, __, model) {
              return IconButton(
                icon: Icon(
                  Icons.navigate_next,
                ),
                onPressed: () {
                  model.resetSubmitStatus();
                  model.isReadyToSubmit
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailsSectionView()))
                      : Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text(tapRecordHint)));
                },
              );
            },
          ),
        )
      ],
    );

    return Scaffold(
      appBar: _appBar,
      backgroundColor: Colors.brown,
      body: RecordSectionView(),
    );
  }
}
