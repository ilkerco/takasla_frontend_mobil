import 'package:flutter/material.dart';

class ImageNotifier with ChangeNotifier {
  List<String> _imagesList = [];
  String? _currentImage;

  void clearCurrentImage() {
    _currentImage = null;
  }

  set currentImage(String path) {
    _currentImage = path;
    notifyListeners();
  }

  set imagesList(List<String> imagesList) {
    _imagesList = imagesList;
  }

  String? GetCurrentImage() {
    if (_currentImage != null) {
      return _currentImage;
    }
    return null;
  }

  List<String> get imagesList => _imagesList;

  void addImage(String imagePath) {
    _imagesList.add(imagePath);
    //notifyListeners();
  }

  void removeImage(String imagePath) {
    _imagesList.remove(imagePath);
    notifyListeners();
  }
}
