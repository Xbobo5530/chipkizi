import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/pages/player.dart';

import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';

import 'package:chipkizi/views/genre_chips.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/progress_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

    final _submitButton =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return Builder(builder: (context) {
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
    });

    Widget _buildProgressButton(MainModel model) => ProgressButton(
          color: Colors.white,
          button: IconButton(
            onPressed: () {},
            icon: model.uploadStatus == StatusCode.success
                ? Icon(
                    Icons.done,
                    size: 80.0,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.file_upload,
                    size: 80.0,
                  ),
          ),
          size: 150.0,
          indicator: model.uploadStatus == StatusCode.success
              ? Container()
              : MyProgressIndicator(
                  color: Colors.orange,
                  value: null,
                  size: 150.0,
                ),
        );

    Widget _buildTextSection(MainModel model) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            model.uploadStatus == StatusCode.success
                ? submitSuccessText
                : waitText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
        );

    Widget _buildWaitingScreen(MainModel model) => Scaffold(
          backgroundColor: Colors.brown,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildProgressButton(model),
                _buildTextSection(model),
                model.uploadStatus == StatusCode.success
                    ? ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.white,
                            textColor: Colors.brown,
                            child: Text(goHomeText),
                            onPressed: () {
                              Navigator.popUntil(
                                  context, ModalRoute.withName('/'));
                            },
                          ),
                          RaisedButton(
                            color: Colors.white,
                            textColor: Colors.brown,
                            child: Text(openRecordingText),
                            onPressed: () async {
                              Recording newRecording =
                                  model.lastSubmittedRecording;
                              List<Recording> recordings =
                                  model.getAllRecordings(newRecording);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerPage(
                                          recording: newRecording,
                                          recordings: recordings,
                                        ),
                                  ),
                                  ModalRoute.withName('/'));
                            },
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return //SubmitRecordingSuccessView();

            model.uploadStatus == StatusCode.waiting
                ? _buildWaitingScreen(model)
                : model.uploadStatus == StatusCode.success
                    ? _buildWaitingScreen(model) //SubmitRecordingSuccessView()
                    : Scaffold(
                        backgroundColor: Colors.brown,
                        appBar: _appBar,
                        body: Column(
                          children: <Widget>[
                            _buildField(_titleController, 1, Icons.title,
                                titleText, FontWeight.bold),
                            _buildField(
                                _descriptionController,
                                null,
                                Icons.description,
                                descriptionText,
                                FontWeight.normal),
                            Expanded(child: _genresSection),
                          ],
                        ),
                        floatingActionButton: _submitButton,
                      );
      },
    );
  }
}
