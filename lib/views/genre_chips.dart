import 'package:chipkizi/models/main_model.dart';
import 'package:flutter/material.dart';

class GenreChipsView extends StatelessWidget {
  final MainModel model;
  final String selectedGenre;
  final bool isSelected;
  final List<String> genresKeys;

  const GenreChipsView(
      {Key key,
      @required this.genresKeys,
      @required this.isSelected,
      @required this.model,
      @required this.selectedGenre})
      : assert(model != null),
        assert(selectedGenre != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: isSelected,
      selectedColor: Colors.lightGreen,
      labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.brown,
          fontWeight: FontWeight.bold),
      onSelected: (isSelected) =>
          model.updateGenres(genresKeys.indexOf(selectedGenre)),
      label: Text(
        selectedGenre,
      ),
    );
  }
}
