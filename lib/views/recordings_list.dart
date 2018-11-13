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
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

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
                            onPressed: () => model.playFromUrl(
//                                'https://firebasestorage.googleapis.com/v0/b/chipkizi-c7705.appspot.com/o/Recordings%2Fbfdbd7f0-e440-11e8-9d50-8f593a9e6f1c.mp4?alt=media&token=346ea347-f375-4b3e-912f-150f58046c6d'
                                  recording.recordingUrl,
                                ),
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
