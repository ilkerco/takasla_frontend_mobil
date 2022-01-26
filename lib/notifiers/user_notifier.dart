import 'package:flutter/material.dart';
import 'package:takasla/models/User.dart';

class UserNotifier with ChangeNotifier {
  User? _currentUser;
  User? _productOwner;

  User? get CurrentUser {
    return _currentUser;
  }

  User? get ProductOwner {
    return _productOwner;
  }

  set setDisplayName(String displayName) {
    _currentUser!.displayName = displayName;
    notifyListeners();
  }

  set setPhotoUrl(String photoUrl) {
    _currentUser!.photoUrl = photoUrl;
    notifyListeners();
  }

  set currentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  set productOwner(User user) {
    _productOwner = user;
    notifyListeners();
  }
}
