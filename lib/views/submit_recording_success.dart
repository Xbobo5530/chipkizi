import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class SubmitRecordingSuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _titleSection = Text('Congratulations');
    Widget _buildImageSection(MainModel model) => CircleAvatar(
          backgroundColor: Colors.black12,
          backgroundImage: NetworkImage(model.currentUser.imageUrl),
        );
    Widget _buildInfoSection(Recording recording) => ListTile(
          title: Text(recording.title),
          subtitle: Text(recording.description),
        );
    return Scaffold(
      backgroundColor: Colors.brown,
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          child: Card(
            color: Colors.white70,
            child: Center(
              child: ScopedModelDescendant<MainModel>(
                builder: (_, __, model) {
                  Recording recording = model.lastSubmittedRecording;
                  return Column(
                    children: <Widget>[
                      _titleSection,
                      _buildImageSection(model),
                      _buildInfoSection(recording)
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
