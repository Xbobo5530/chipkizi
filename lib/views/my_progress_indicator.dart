import 'package:flutter/material.dart';

class MyProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double progress;
  MyProgressIndicator({
    this.color,
    this.progress,
    this.size,
  });
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
