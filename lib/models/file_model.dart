import 'dart:io';

import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

const _tag = 'FileModel:';

abstract class FileModel extends Model {
  final FirebaseStorage storage = FirebaseStorage();
  StorageUploadTask _task;
  String _filePath;
  String get filePath => _filePath;

  String _fileUrl;
  String get fileUrl => _fileUrl;

  Future<File> _imageFile;
  Future<File> get imageFile => _imageFile;

  StatusCode _uploadStatus;
  StatusCode get uploadStatus => _uploadStatus;

  StatusCode getFile() {
    print('$_tag at getFile');
    bool _hasError = false;
    _imageFile =
        ImagePicker.pickImage(source: ImageSource.gallery).catchError((error) {
      print('$_tag error on getting image');
      _hasError = true;
    });

    notifyListeners();
    return _hasError ? StatusCode.failed : StatusCode.success;
  }

  Future<StatusCode> uploadFile(
      String localRecordingPath, FileType type) async {
    print('$_tag at uploadFile');
    bool _hasError = false;
    final String uuid = Uuid().v1();
    final File file = File(localRecordingPath);
    final StorageReference ref =
        storage.ref().child(_getBucket(type)).child(_getFileName(type, uuid));
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'chipkizi'},
      ),
    );
    _task = uploadTask;

    StorageTaskSnapshot snapshot =
        await uploadTask.onComplete.catchError((error) {
      print('$_tag error on uploading recording: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    _fileUrl = await snapshot.ref.getDownloadURL().catchError((error){
      print('$_tag error on getting file url: $error');
      _hasError = true;
    });
    _filePath = await snapshot.ref.getPath().catchError((error){
      print('$_tag error on geting file path: $error');
    });
    print('$_tag the download url is : $_fileUrl');
    if (_hasError) return StatusCode.failed;
    notifyListeners();
    return StatusCode.success;
  }

  String _getBucket(FileType type) {
    switch (type) {
      case FileType.userImages:
        return USER_IMAGE_BUCKET;
        break;
      case FileType.recordingsImage:
        return RECORDINGS_IMAGE_BUCKET;
        break;
      case FileType.recording:
        return RECORDINGS_BUCKET;
        break;
      default:
        return OTHER_BUCKET;
    }
  }

  String _getFileName(FileType type, String uuid) {
    switch (type) {
      case FileType.recording:
        return '$uuid.mp4';
        break;
      case FileType.recordingsImage:
      case FileType.userImages:
        return '$uuid.jpg';
      default:
        return '$uuid';
    }
  }

  resetFileDetails() {
    print('$_tag at resetFileDtails');
    _filePath = null;
    _fileUrl = null;
    _imageFile = null;
    notifyListeners();
  }

  Future<StatusCode> deleteFile(String path) async {
    print('$_tag at deleteFile');
    bool _hasError = false;
    storage.ref().child(path).delete().catchError((error) {
      print('$_tag error on deleting file: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }
}
