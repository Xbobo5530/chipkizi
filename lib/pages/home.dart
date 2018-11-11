import 'package:chipkizi/mock_data/recording_data.dart';
import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/pages/create_recording.dart';
import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/pages/my_profile.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recordings_list.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'package:audio_recorder/audio_recorder.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _openRecordingPage(BuildContext context) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RecordingPage(), fullscreenDialog: true));
    }

    _goToLoginPage() => Navigator.push(context,
        MaterialPageRoute(builder: (_) => LoginPage(), fullscreenDialog: true));

    final _appBarSection =
        AppBar(leading: Icon(Icons.mic_none), title: Text(APP_NAME));

    final _bottomNavSection = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return BottomNavigationBar(
          currentIndex: model.selectedNavItem,
          onTap: (selectedItem) => model.updateSelectedNavItem(selectedItem),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text(homeText)),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), title: Text(meText)),
          ],
        );
      },
    );

    final _fabSection = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return FloatingActionButton(
            child: Icon(Icons.mic),
            heroTag: 'open recording page',
            onPressed: model.isLoggedIn
                ? () => _openRecordingPage(context)
                : () => _goToLoginPage());
      },
    );

    final _loginView = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loginToViewProfileMessage,
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
              color: Colors.brown,
              textColor: Colors.white,
              onPressed: () => _goToLoginPage(),
              child: Text(loginText)),
        ],
      ),
    );

    final _body = ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        switch (model.selectedNavItem) {
          case NAV_ITEM_HOME:
            return RecordingsListView();
            break;
          case NAV_ITEM_ME:
            return model.isLoggedIn ? MyProfilePage() : _loginView;
            break;
        }
      },
    );

    return Scaffold(
      appBar: _appBarSection,
      body: _body,
      bottomNavigationBar: _bottomNavSection,
      floatingActionButton: _fabSection,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
