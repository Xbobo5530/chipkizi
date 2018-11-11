import 'package:flutter/material.dart';

class MyProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double progress;

  const MyProgressIndicator(
      {Key key,
      @required this.size,
      @required this.color,
      @required this.progress})
      : super(key: key);
//  MyProgressIndicator({
//    @required this.color,
//    @required this.progress,
//    @required this.size,
//  });
  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        child: Theme(
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12.0,
          ),
          data: Theme.of(context).copyWith(accentColor: color),
        ));
  }
}
