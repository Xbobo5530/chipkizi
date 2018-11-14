import 'package:chipkizi/models/account_model.dart';
import 'package:chipkizi/models/navigation_model.dart';
import 'package:chipkizi/models/recording_model.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model
    with AccountModel, RecordingModel, NavigationModel {
  MainModel() {
    updateLoginStatus();
    getRecordings();
  }
}
