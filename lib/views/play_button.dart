import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/values/status_code.dart';

import 'package:chipkizi/views/circular_button.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'PlayButtonView:';
class PlayButtonView extends StatelessWidget {
  final Recording recording;

  const PlayButtonView({Key key, @required this.recording})
      : assert(recording != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return FutureBuilder<PlaybackStatus>(
          initialData: PlaybackStatus.stopped,
          future: model.getPlayStatusFor(recording),
                  builder: (context, snapshot){

                    PlaybackStatus status = snapshot.data;
                    print ('$_tag status no future builder is: $status');
                    return CircularIconButton(
            size: 60.0,
            button: status == PlaybackStatus.playing
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
                    onPressed: () => model.play(recording) //model.playFromUrl(recording.recordingUrl),
                  ),
            color: Colors.white,
          );
                  } ,
        );
      },
    );
  }
}
