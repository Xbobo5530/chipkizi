import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/details_section.dart';
import 'package:chipkizi/views/record_section.dart';
import 'package:flutter/material.dart';

class RecordingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(APP_NAME),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.navigate_next,
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => DetailsSectionView())),
          )
        ],
      ),
      backgroundColor: Colors.brown,
      body: RecordSectionView(),
    );
  }
}
