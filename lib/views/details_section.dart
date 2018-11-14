import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/recording_model.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/genre_chips.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/progress_button.dart';
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

    Future<void> _handleSubmit(BuildContext context, MainModel model) async {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      if (title.isNotEmpty && description.isNotEmpty) {
        final recording = Recording(
            title: title,
            description: description,
            createdBy: model.currentUser.id,
            createdAt: DateTime.now().millisecondsSinceEpoch);
        StatusCode submitStatus = await model.handleSubmit(recording);
        if (submitStatus == StatusCode.failed)
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
          ));
        if (submitStatus == StatusCode.success)
          Navigator.pushNamed(context, '/');
      }
    }

    final _appBar = AppBar(
      elevation: 0.0,
      title: Hero(tag: TAG_APP_TITLE, child: Text(APP_NAME)),
      centerTitle: true,
      leading: Hero(
        tag: TAG_NEXT_BACK_BUTTON,
        child: IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () => Navigator.pop(context)),
      ),
    );

    Widget _buildField(TextEditingController controller, int maxLines,
            IconData iconData, String labelText, FontWeight labelFontWeight) =>
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Theme(
            data: Theme.of(context).copyWith(
                accentColor: Colors.white, primaryColor: Colors.white),
            child: TextField(
                style: TextStyle(color: Colors.white),
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      iconData,
                      color: whitish,
                    ),
                    suffixIcon: Icon(
                      Icons.edit,
                      color: whitish,
                    ),
                    labelText: labelText,
                    labelStyle: TextStyle(
                        fontWeight: labelFontWeight, color: whitish))),
          ),
        );

    final _genresSection = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return StaggeredGridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          primary: false,
          mainAxisSpacing: 4.0,
          children: model.genres.keys.map((genreTitle) {
            return GenreChipsView(
              isSelected: model.genres[genreTitle],
              selectedGenre: genreTitle,
              model: model,
              genresKeys: model.genres.keys.toList(),
            );
          }).toList(),
          staggeredTiles:
              model.genres.keys.map((genre) => StaggeredTile.fit(1)).toList(),
        );
      },
    );

    Widget _buildSubmitButton(MainModel model) => Builder(builder: (context) {
          return Hero(
            tag: TAG_MAIN_BUTTON,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => _handleSubmit(context, model),
              child: Icon(
                Icons.file_upload,
                color: Colors.green,
              ),
            ),
          );
        });

    final _progressButton = ProgressButton(
      color: Colors.white,
      button: IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.file_upload,
          size: 80.0,
        ),
      ),
      size: 150.0,
      indicator: MyProgressIndicator(
        color: Colors.orange,
        value: null,
        size: 150.0,
      ),
    );

    final _waitingText = Title(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            waitText,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        ));

    final _waitingScreen = Scaffold(
      backgroundColor: Colors.brown,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _progressButton,
            _waitingText,
          ],
        ),
      ),
    );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return model.uploadStatus == StatusCode.waiting
            ? _waitingScreen
            : Scaffold(
                backgroundColor: Colors.brown,
                appBar: _appBar,
                body: Column(
                  children: <Widget>[
//                    _titleField,
//                    _descField,
                    _buildField(_titleController, 1, Icons.title, titleText,
                        FontWeight.bold),
                    _buildField(_descriptionController, null, Icons.description,
                        descriptionText, FontWeight.normal),
                    Expanded(child: _genresSection),
                  ],
                ),
                floatingActionButton: _buildSubmitButton(model),
              );
      },
    );
  }
}
