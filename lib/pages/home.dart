import 'package:chipkizi/models/main_model.dart';

import 'package:chipkizi/pages/create_recording.dart';

import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/pages/my_profile.dart';
import 'package:chipkizi/pages/searrch_delegate.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recordings_list.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

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

    _handleSearch(MainModel model) async {
      await showSearch(
        context: context,
        delegate: RecordingsSearch(recordings: model.recordings),
      );
    }

    _logout(MainModel model) async {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(confirmLogoutText),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {model.logout();Navigator.pop(context);},
                  child: Text(logoutText),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(cancelText),
                )
              ],
            );
          });
    }

    final _appBarSection = AppBar(
      leading: Icon(Icons.mic_none),
      title: Hero(
          flightShuttleBuilder: (context, animatrion, direction, _, __) {
            return Icon(
              Icons.fiber_manual_record,
              color: Colors.white,
            );
          },
          tag: TAG_APP_TITLE,
          child: Text(APP_NAME)),
      centerTitle: true,
      actions: <Widget>[
        ScopedModelDescendant<MainModel>(
          builder: (_, __, model) => model.isLoggedIn
              ? IconButton(
                  icon: Icon(model.selectedNavItem == NAV_ITEM_HOME
                      ? Icons.search
                      : Icons.exit_to_app),
                  onPressed: model.selectedNavItem == NAV_ITEM_HOME
                      ? () => _handleSearch(model)
                      : () => _logout(model),
                )
              : model.selectedNavItem == NAV_ITEM_HOME
                  ? IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => _handleSearch(model))
                  : Container(),
        )
      ],
    );

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
        return Hero(
          child: FloatingActionButton(
              child: Icon(Icons.mic),
              heroTag: 'open recording page',
              onPressed: model.isLoggedIn
                  ? () => _openRecordingPage(context)
                  : () => _goToLoginPage()),
          tag: TAG_MAIN_BUTTON,
        );
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
