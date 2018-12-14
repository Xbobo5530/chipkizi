import 'dart:io';

import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class MyProfileImageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _handleUpdateImage(MainModel model, File image) async {
      model.setUplaodWaitingStatus();
      if (model.currentUser.imagePath != null)
        await model.deleteFile(model.currentUser.imagePath);

      StatusCode uplaodStatus =
          await model.uploadFile(image.path, FileType.userImages);
      if (uplaodStatus == StatusCode.failed) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
        model.resetFileDetails();
        return null;
      }
      User currentUser = model.currentUser;
      currentUser.imageUrl = model.fileUrl;
      currentUser.imagePath = model.filePath;
      StatusCode updateProfileStatus =
          await model.editAccountDetails(currentUser, DetailType.imageUrl);
      if (updateProfileStatus == StatusCode.failed) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
        model.resetFileDetails();
        return null;
      }
      model.resetFileDetails();
    }

    _buildEditButton(MainModel model, File imageFile) => Positioned(
          bottom: 0.0,
          right: 0.0,
          child: Opacity(
            opacity: 0.7,
            child: CircularIconButton(
              size: 40.0,
              button: IconButton(
                icon: model.editingUserDetailsStatus == StatusCode.waiting
                    ? MyProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white70,
                        size: 15.0,
                        value: null,
                      )
                    : Icon(
                        model.imageFile != null ? Icons.done : Icons.edit,
                        color: Colors.white70,
                      ),
                onPressed: model.imageFile != null
                    ? () => _handleUpdateImage(model, imageFile)
                    : () => model.getFile(),
              ),
              color: Colors.black,
            ),
          ),
        );
    _buildImageSection(MainModel model, AsyncSnapshot snapshot,File imageFile) => CircleAvatar(
          radius: 60.0,
          backgroundColor: Colors.brown,
          backgroundImage: snapshot.hasData
              ? FileImage(imageFile)
              : model.currentUser.imageUrl != null
                  ? NetworkImage(model.currentUser.imageUrl)
                  : AssetImage(ASSET_LAUNCHER_ICON),
        );

    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => Center(
              child: FutureBuilder<File>(
            future: model.imageFile,
            builder: (context, snapshot) {
              File imageFile = snapshot.data;
              return Stack(
                children: <Widget>[
                  _buildImageSection(model, snapshot,imageFile),
                  _buildEditButton(model, imageFile),
                ],
              );
            },
          )),
    );
  }
}
