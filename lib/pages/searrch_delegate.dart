import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/views/recordings_list_item.dart';
import 'package:flutter/material.dart';

class RecordingsSearch extends SearchDelegate<Recording> {
  final Map<String, Recording> recordings;

  RecordingsSearch(this.recordings);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Recording> resultsList = <Recording>[];
    recordings.forEach((id, recording) {
      if ((recording.title.toLowerCase().contains(query.toLowerCase())) ||
          recording.description.toLowerCase().contains(query.toLowerCase()))
        resultsList.add(recording);
    });
    return ListView.builder(
      itemCount: resultsList.length,
      itemBuilder: (context, index) {
        return RecordingsListItemView(
            key: Key(resultsList[index].id), recording: resultsList[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    List<Recording> resultsList = <Recording>[];
    recordings.forEach((id, recording) {
      if ((recording.title.toLowerCase().contains(query.toLowerCase())) ||
          recording.description.toLowerCase().contains(query.toLowerCase()))
        resultsList.add(recording);
    });
    return ListView.builder(
      itemCount: resultsList.length,
      itemBuilder: (context, index) {
        return RecordingsListItemView(
            key: Key(resultsList[index].id), recording: resultsList[index]);
      },
    );
  }
}
