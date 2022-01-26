import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:takasla/models/Products.dart';

class ProductNotifier with ChangeNotifier {
  List<Product> _productList = [];
  List<Product> _usersProductList = [];

  Product? _currentProduct;

  UnmodifiableListView<Product> get productList =>
      UnmodifiableListView(_productList);
  UnmodifiableListView<Product> get userProductList =>
      UnmodifiableListView(_usersProductList);

  Product? GetCurrentProduct() {
    return _currentProduct;
  }

  set productList(List<Product> productList) {
    _productList = productList;
    notifyListeners();
  }

  set usersProductList(List<Product> productList) {
    _usersProductList = productList;
    notifyListeners();
  }

  set currentProduct(Product product) {
    _currentProduct = product;
    notifyListeners();
  }
}
