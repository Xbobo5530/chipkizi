import 'package:flutter/material.dart';

class GenreChipView extends StatelessWidget {
  final String genre;

  const GenreChipView({Key key, this.genre}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            genre,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12.0),
          ),
        ),
        decoration: BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.circular(16.0)),
      ),
    );
  }
}
