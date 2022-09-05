import 'package:flutter/material.dart';
import 'package:jojo/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    email: '',
    name: '',
    uid: '',
  );

  User get user => _user;

  setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
