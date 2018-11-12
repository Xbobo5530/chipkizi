import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';
import 'package:chipkizi/views/progress_button.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'LoginPage:';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _handleLogin(BuildContext context, MainModel model) async {
      StatusCode statusCode = await model.loginWithGoogle();

      switch (statusCode) {
        case StatusCode.success:
          Navigator.pop(context);
          break;
        case StatusCode.failed:
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage)));
          break;
        default:
          print('$_tag unhandled status code: $statusCode');
      }
    }

    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(loginText),
      ),
      body: Center(
        child: ScopedModelDescendant<MainModel>(
          builder: (_, __, model) {
            return Builder(
              builder: (context) {
                return Hero(
                  tag: 'Record Button',
                  child: ProgressButton(
                    color: Colors.white,
                    button: IconButton(
                      icon: Icon(
                        Icons.lock,
                        size: 80,
                      ),
                      onPressed: () => _handleLogin(context, model),
                    ),
                    size: 150.0,
                    indicator: MyProgressIndicator(
                      color: Colors.orange,
                      progress:
                          model.loginStatus == StatusCode.waiting ? null : 0.0,
                      size: 50.0,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
