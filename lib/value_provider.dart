import 'package:flutter/cupertino.dart';

class ValueProvider with ChangeNotifier {
  String value = '0';
  void updateValue(String toUpdate) {
    if (toUpdate.length != 2) {
      this.value = toUpdate;
      // print('New Value: ${this.value}\n');
      notifyListeners();
    }
  }
}
