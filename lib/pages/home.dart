import 'package:chipkizi/models/main_model.dart';

import 'package:chipkizi/pages/create_recording.dart';

import 'package:chipkizi/pages/login.dart';
import 'package:chipkizi/pages/my_profile.dart';
import 'package:chipkizi/pages/searrch_delegate.dart';
import 'package:chipkizi/values/consts.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/recordings_list.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:package_info/package_info.dart';

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
                  onPressed: () {
                    model.logout();
                    Navigator.pop(context);
                  },
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

    _buildButtons(String label, AppInfoAction action) =>
        ScopedModelDescendant<MainModel>(
            builder: (context, child, model) => InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                  ),
                  onTap: () => model.handleApInfoAction(action),
                ));

    _handleShowAppInfo() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return showAboutDialog(
          context: context,
          applicationIcon: CircleAvatar(
            backgroundColor: Colors.brown,
            backgroundImage: AssetImage(ASSET_APP_ICON),
          ),
          applicationName: packageInfo.appName,
          applicationVersion: packageInfo.version,
          children: <Widget>[
            Text(developedByText),
            _buildButtons(callText, AppInfoAction.call),
            _buildButtons(emailText, AppInfoAction.email),
            _buildButtons(moreText, AppInfoAction.more)
          ]);
    }

    final _appBarSection = AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => _handleShowAppInfo(),
          child: Image.asset(
            ASSET_APP_ICON,
          ),
        ),
      ),
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
        return Material(
          elevation: 8.0,
          child: BottomNavigationBar(
            currentIndex: model.selectedNavItem,
            onTap: (selectedItem) => model.updateSelectedNavItem(selectedItem),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text(homeText)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), title: Text(meText)),
            ],
          ),
        );
      },
    );

    final _fabSection = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return Hero(
          child: FloatingActionButton(
              child: Icon(Icons.mic),
              heroTag: 'TAG_MAIN_BUTTON,', //'open recording page',
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
          default:
            return RecordingsListView();
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
