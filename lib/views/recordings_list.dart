import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/views/recordings_list_item.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class RecordingsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return StreamBuilder(
          stream: model.recordingsStream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, index) {
                  final document = snapshot.data.documents[index];
                  Recording recording = Recording.fromSnaspshot(document);
                  return FutureBuilder<Recording>(
                    initialData: recording,
                    future: model.refineRecording(recording),
                      builder: (context, snapshot) => RecordingsListItemView(
                          recording: recording, key: Key(recording.id)));
                });
          },
        );
      },
    );
  }
}
