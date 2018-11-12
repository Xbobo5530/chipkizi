import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/views/circular_button.dart';
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
            if (!snapshot.hasData) return CircularProgressIndicator();

            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, index) {
                  final document = snapshot.data.documents[index];
                  Recording recording = Recording.fromSnaspshot(document);
                  return ScopedModelDescendant<MainModel>(
                    builder: (_, __, model) {
                      return ListTile(
                        title: Text(recording.title),
                        subtitle: Text(recording.description),
                        trailing: Material(
                          shape: CircleBorder(),
                          elevation: 4.0,
                          child: IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              size: 30.0,
                              color: Colors.green,
                            ),
                            onPressed: () =>
                                model.playFromUrl(recording.recordingUrl),
                          ),
                        ),
                      );
                    },
                  );
                });
          },
        );
      },
    );
  }
}
