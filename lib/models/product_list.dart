import 'package:flutter/material.dart';
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

// provider
class ProductList with ChangeNotifier {
  final List<Product> _items = dummyProducts;

  List<Product> get items => [..._items]; // [..._items] cópia de items

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }
}