import 'package:scoped_model/scoped_model.dart';

abstract class NavigationModel extends Model {
  int _selectedNavItem = 0;
  int get selectedNavItem => _selectedNavItem;

  updateSelectedNavItem(int selectedItem) {
    _selectedNavItem = selectedItem;
    notifyListeners();
  }
}
