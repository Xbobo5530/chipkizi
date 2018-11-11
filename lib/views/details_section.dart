import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class DetailsSectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    _handleSubmit(MainModel model) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      if (title.isNotEmpty && description.isNotEmpty) {
        final recording = Recording(
          title: title,
          description: description,
        );
        model.handleSubmit(recording);
      }
    }

    return Column(
      children: <Widget>[
        TextField(),
        TextField(),
        ScopedModelDescendant<MainModel>(
          builder: (_, __, model) {
            return RaisedButton(
              onPressed: () => _handleSubmit(model),
              child: Text(submitText),
            );
          },
        )
      ],
    );
  }
}
