import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class DetailsSectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final whitish = Colors.white70;
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    _handleSubmit(MainModel model) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      if (title.isNotEmpty && description.isNotEmpty) {
        final recording = Recording(
            title: 'test title', // title,
            description: 'test description', //description,
            genre: ['funk', 'jazz'], //model.selectedGenres,
            createdBy: model.currentUser.id,
            createdAt: DateTime.now().millisecondsSinceEpoch);
        model.handleSubmit(recording);
      }
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Theme(
            data: Theme.of(context).copyWith(
                accentColor: Colors.white, primaryColor: Colors.white),
            child: TextField(
              controller: _titleController,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.title,
                    color: whitish,
                  ),
                  suffixIcon: Icon(
                    Icons.edit,
                    color: whitish,
                  ),
                  labelText: titleText,
                  labelStyle: TextStyle(
                    color: whitish,
                  )),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Theme(
            data: Theme.of(context).copyWith(
                accentColor: Colors.white, primaryColor: Colors.white),
            child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _descriptionController,
                maxLines: null,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.description,
                      color: whitish,
                    ),
                    suffixIcon: Icon(
                      Icons.edit,
                      color: whitish,
                    ),
                    labelText: descriptionText,
                    labelStyle: TextStyle(
                        color: whitish, fontStyle: FontStyle.italic))),
          ),
        ),
        Container(
          height: 80.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: genres
                .map((genre) => Padding(
                      child: ChoiceChip(
                        label: Text(genre),
                        selected: false,
                      ),
                      padding: const EdgeInsets.all(8.0),
                    ))
                .toList(),
          ),
        ),
        ScopedModelDescendant<MainModel>(
          builder: (_, __, model) {
            return CircularIconButton(
              color: Colors.white,
              button: IconButton(
                  onPressed: () {}, //=> _handleSubmit(model),
                  icon: Icon(
                    Icons.file_upload,
                    color: Colors.green,
                  )),
            );

            RaisedButton(
              onPressed: () => _handleSubmit(model),
              child: Text(submitText),
            );
          },
        )
      ],
    );
  }
}
