import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';

import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';

import 'package:chipkizi/views/genre_chips.dart';

import 'package:chipkizi/views/wait_view.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class DetailsSectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final whitish = Colors.white70;
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
          model.resetTempDetailsFieldValues();
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

    // Widget _buildField(TextEditingController controller, int maxLines,
    //         IconData iconData, String labelText, FontWeight labelFontWeight) =>
    //     Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Theme(
    //         data: Theme.of(context).copyWith(
    //             accentColor: Colors.white, primaryColor: Colors.white),
    //         child: TextField(
    //             style: TextStyle(color: Colors.white),
    //             controller: controller,
    //             maxLines: maxLines,
    //             decoration: InputDecoration(
    //                 border: InputBorder.none,
    //                 prefixIcon: Icon(
    //                   iconData,
    //                   color: whitish,
    //                 ),
    //                 suffixIcon: Icon(
    //                   Icons.edit,
    //                   color: whitish,
    //                 ),
    //                 labelText: labelText,
    //                 labelStyle: TextStyle(
    //                     fontWeight: labelFontWeight, color: whitish))),
    //       ),
    //     );

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

    Future<void> _hanldeSubmit(MainModel model, DetailType type) async {}

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
                controller: type == DetailType.title
                    ? _titleController
                    : _descriptionController,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(cancelText),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                    child: Text(submitText),
                    onPressed: () {
                      _hanldeSubmit(model, type);
                      Navigator.pop(context);
                    }),
              ],
            );
          });
    }

    Widget _buildBody(MainModel model) => Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.title),
              title:
                  Text(model.tempTitle != null ? model.tempTitle : titleText),
              trailing: Icon(Icons.edit),
              onTap: () => _showEditDialog(model, DetailType.title),
            ),

            ListTile(
              leading: Icon(Icons.description),
              title: Text(model.tempDescription != null
                  ? model.tempDescription
                  : descriptionText),
              trailing: Icon(Icons.edit),
              onTap: () => _showEditDialog(model, DetailType.description),
            ),

            // Row(
            //   children: <Widget>[
            //     Icon(Icons.title),
            //     Expanded(
            //       child: Text(titleText),
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.edit),
            //       onPressed: (){},
            //     )
            //   ],
            // ),
            // Row(
            //   children: <Widget>[
            //     Icon(Icons.description),
            //     Expanded(
            //       child: Text(descriptionText),
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.edit),
            //       onPressed: (){},
            //     )
            //   ],
            // ),
            // _buildField(
            //     _titleController, 1, Icons.title, titleText, FontWeight.bold),
            // _buildField(_descriptionController, null, Icons.description,
            //     descriptionText, FontWeight.normal),
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
        return model.uploadStatus == StatusCode.waiting
            ? WaitView()
            : model.uploadStatus == StatusCode.success
                ? WaitView()
                : _buidlDetailsSection(model);
      },
    );
  }
}
