import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/constants.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';

// provider
class ProductList with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Product> _items = [];

  final _baseUrl = Constants.productBaseUrl;

  List<Product> get items => [..._items]; // [..._items] cópia de items
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  ProductList(
      [this._token = '',
      this._userId = '',
      this._items =
          const []]); // entre colchetes significa parâmetros opcionais

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadProducts() async {
    _items.clear();

    final response = await http.get(Uri.parse('$_baseUrl.json?auth=$_token'));
    if (response.body == 'null') return;

    final favResponse = await http.get(Uri.parse(
        '${Constants.userFavoritesBaseUrl}/$_userId.json?auth=$_token'));

    Map<String, dynamic> favData =
        favResponse.body == 'null' ? {} : jsonDecode(favResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ),
      );
    });
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
        id: hasId ? data['id'] as String : Random().nextDouble().toString(),
        name: data['name'] as String,
        description: data['description'] as String,
        price: data['price'] as double,
        imageUrl: data['imageUrl'] as String);

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    // no firebase para persistir os dados, precisa colocar o .json no final
    final response = await http.post(Uri.parse('$_baseUrl.json?auth=$_token'),
        body: jsonEncode({
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
        }));

    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse('$_baseUrl/${product.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('$_baseUrl/${product.id}.json?auth=$_token'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
            msg: "Não foi possível excluir o produto",
            statusCode: response.statusCode);
      }
    }
  }
}


// Declarar provider de forma global no app
// bool _showFavoriteOnly = false;

//   List<Product> get items {
//     if (_showFavoriteOnly) {
//       return _items.where((prod) => prod.isFavorite).toList();
//     }
//     return [..._items];
//   }

//   void showFavoriteOnly() {
//     _showFavoriteOnly = true;
//     notifyListeners();
//   }

//   void showAll() {
//     _showFavoriteOnly = false;
//     notifyListeners();
//   }
