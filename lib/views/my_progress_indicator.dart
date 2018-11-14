import 'package:flutter/material.dart';

class MyProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;
  /// A [double] value [value] that shows the value to be displayed
  /// by the determinent [CircularProgressIndicator]
  final double value;
  final double strokeWidth;
  /// Whether the [CircularProgressIndicator] should appear
  /// at the center of the [Container] or outsie the [Container]
  /// by default the indicator appears outside the container
  final bool isCentered;

  const MyProgressIndicator(
      {Key key,
      @required this.size,
      @required this.color,
      @required this.value, 
      this.strokeWidth = 12.0,
      this.isCentered = false
      })
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
          child: isCentered ? Center(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
            ),
          ) :CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
            )
          ,
          data: Theme.of(context).copyWith(accentColor: color),
        ));
  }
}
