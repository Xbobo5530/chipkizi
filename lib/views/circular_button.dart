import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconButton button;
  final Color color;
  CircularIconButton({@required this.button, @required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      color: color,
      shape: CircleBorder(),
      child: button,
    );
  }
}
