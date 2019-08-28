import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/genre_chips.dart';
import 'package:chipkizi/views/wait_view.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'DetailsSectionView:';

class DetailsSectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    Future<void> _handleSubmit(BuildContext context, MainModel model) async {
      final title = model.tempTitle;
      final description = model.tempDescription;
      if (title.isEmpty || description.isEmpty) return null;

      model.setSubmitStatus();

      final recording = Recording(
          title: title,
          description: description,
          createdBy: model.currentUser.id,
          createdAt: DateTime.now().millisecondsSinceEpoch);

      StatusCode uploadStatus = await model.uploadFile(
          model.defaultRecordingPath, FileType.recording);
      if (uploadStatus == StatusCode.failed) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
        return null;
      }
      if (model.filePath == null || model.fileUrl == null) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
        return null;
      }
      recording.recordingPath = model.filePath;
      recording.recordingUrl = model.fileUrl;

      StatusCode submitStatus = await model.handleSubmit(recording);
      if (submitStatus == StatusCode.failed)
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
      if (submitStatus == StatusCode.success)
        model.resetTempDetailsFieldValues();
      model.resetFileDetails();
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

    final _genresSection = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return GridView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 3.0),
          children: model.genres.keys.map((genreTitle) {
            return GenreChipsView(
              isSelected: model.genres[genreTitle],
              selectedGenre: genreTitle,
              model: model,
              genresKeys: model.genres.keys.toList(),
            );
          }).toList(),
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

    Future<void> _updateFields(MainModel model, DetailType type) async {
      print('$_tag at _updateFields');
      String value;
      switch (type) {
        case DetailType.title:
          value = _titleController.text.trim();

          break;
        case DetailType.description:
          value = _descriptionController.text.trim();
          break;
        default:
          print('$_tag unexpected type');
      }

      if (value == null || value.isEmpty) return null;
      model.setTempValues(value, type);
    }

    _showEditDialog(MainModel model, DetailType type) async {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:
                  Text(type == DetailType.title ? titleText : descriptionText),
              content: TextField(
                autofocus: true,
                maxLines: type == DetailType.title ? 1 : null,
                cursorColor: Colors.brown,
                textCapitalization: type == DetailType.title
                    ? TextCapitalization.words
                    : TextCapitalization.sentences,
                controller: type == DetailType.title
                    ? _titleController
                    : _descriptionController,
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.grey,
                  child: Text(cancelText),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                    child: Text(submitText),
                    onPressed: () {
                      type == DetailType.title
                          ? _titleController.text.trim()
                          : _descriptionController.text.trim();
                      _updateFields(model, type);
                      Navigator.pop(context);
                    }),
              ],
            );
          });
    }

    Widget _buildBody(MainModel model) => Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.title,
                color: Colors.white,
              ),
              title: Text(
                model.tempTitle != null ? model.tempTitle : titleText,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                Icons.edit,
                color: Colors.white70,
              ),
              onTap: () => _showEditDialog(model, DetailType.title),
            ),
            ListTile(
              leading: Icon(
                Icons.description,
                color: Colors.white,
              ),
              title: Text(
                model.tempDescription != null
                    ? model.tempDescription
                    : descriptionText,
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.edit,
                color: Colors.white70,
              ),
              onTap: () => _showEditDialog(model, DetailType.description),
            ),
            Expanded(child: _genresSection),
          ],
        );

    Widget _buidlDetailsSection(MainModel model) => Scaffold(
          backgroundColor: Colors.brown,
          appBar: _appBar,
          body: _buildBody(model),
          floatingActionButton: _submitButton,
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return model.submitStatus == StatusCode.waiting
            ? WaitView()
            : model.submitStatus == StatusCode.success
                ? WaitView()
                : _buidlDetailsSection(model);
      },
    );
  }
}
