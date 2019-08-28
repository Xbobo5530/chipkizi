import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class NavigationModel extends Model {
  int _selectedNavItem = 0;
  int get selectedNavItem => _selectedNavItem;

  updateSelectedNavItem(int selectedItem) {
    _selectedNavItem = selectedItem;
    notifyListeners();
  }

  handleApInfoAction(AppInfoAction action) {
    switch (action) {
      case AppInfoAction.call:
        _launchURL(URL_CALL);
        break;
      case AppInfoAction.email:
        _launchURL(URL_EMAIL);
        break;
      case AppInfoAction.more:
        _launchURL(URL_MORE);
        break;
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  goToLogin(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(), fullscreenDialog: true));
}
