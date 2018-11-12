import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/recording_model.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const _tag = 'DetailsSectionView:';

class DetailsSectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final whitish = Colors.white70;
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    _handleSubmit(MainModel model) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
//      if (title.isNotEmpty && description.isNotEmpty) {
      final recording = Recording(
          title: 'test title', // title,
          description: 'test description', //description,
          genre: ['funk', 'jazz'], //model.selectedGenres,
          createdBy: model.currentUser.id,
          createdAt: DateTime.now().millisecondsSinceEpoch);
      model.handleSubmit(recording);
//      }
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
        ScopedModelDescendant<MainModel>(
          builder: (_, __, model) {
            return Container(
              height: 150.0,
              child: StaggeredGridView.builder(
                itemCount: model.genres.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  print('$_tag key are: ${model.genres.keys.elementAt(index)}');
                  return Text('${model.genres.keys.elementAt(index)}');
                  return ChoiceChip(
                    label: Text(model.genres.keys.elementAt(index)),
                    selected: model.genres[index],
                  );
                },
                gridDelegate:
                    SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        staggeredTileBuilder: (count) =>
                            StaggeredTile.fit(model.genres.length)),
              ),
            );
          },
        ),
        ScopedModelDescendant<MainModel>(
          builder: (_, __, model) {
            return CircularIconButton(
              color: Colors.white,
              button: IconButton(
                  onPressed: () => _handleSubmit(model),
                  icon: Icon(
                    Icons.file_upload,
                    color: Colors.green,
                  )),
            );
          },
        )
      ],
    );
  }
}
