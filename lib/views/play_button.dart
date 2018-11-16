import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/status_code.dart';

import 'package:chipkizi/views/circular_button.dart';
import 'package:chipkizi/views/my_progress_indicator.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'PlayButtonView:';

class PlayButtonView extends StatefulWidget {
  final Recording recording;

  const PlayButtonView({Key key, @required this.recording})
      : assert(recording != null),
        super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<PlayButtonView> {
  PlaybackStatus _playbackStatus;
  bool _isDisposed = false;

  @override
  void initState() {
    _isDisposed = false;
    _playbackStatus = PlaybackStatus.stopped;
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    _handlePlay(MainModel model) async {
      print('$_tag at _handlePlay');
      if (!_isDisposed)
        setState(() {
          _playbackStatus = PlaybackStatus.loading;
        });
      PlaybackStatus status = await model.play(widget.recording);
      print('$_tag at _handlePlay, status is: $status');
      if (!_isDisposed)
        setState(() {
          _playbackStatus = status;
        });
    }

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return CircularIconButton(
          size: 60.0,
          button: _playbackStatus == PlaybackStatus.loading
              ? MyProgressIndicator(
                  color: Colors.brown,
                  size: 15.0,
                  value: null,
                  strokeWidth: 4.0,
                )
              : _playbackStatus == PlaybackStatus.playing
                  ? IconButton(
                      icon: Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: 32.0,
                      ),
                      onPressed: () => model.stop(),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: Colors.green,
                        size: 32.0,
                      ),
                      onPressed: () => _handlePlay(
                          model) //model.playFromUrl(recording.recordingUrl),
                      ),
          color: Colors.white,
        );
      },
    );
  }
}

// class PlayButtonView extends StatelessWidget {

// }
