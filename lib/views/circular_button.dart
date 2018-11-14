import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconButton button;
  final Color color;
  final double size;

  const CircularIconButton({Key key, this.button, this.color, this.size = 48.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size,
        width: size,
        child: button,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
