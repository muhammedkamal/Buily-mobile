import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exceptions.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /* Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://assets.rebelmouse.io/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpbWFnZSI6Imh0dHBzOi8vYXNzZXRzLnJibC5tcy8xOTQwOTA1MS9vcmlnaW4uanBnIiwiZXhwaXJlc19hdCI6MTY0OTY4Mjc1MX0.Gi9_iy8LMozNmkOc0tuWxXNDOZyvYJ5Qg_Musl0yJA4/img.jpg?width=980&quality=85',
    ) */
  ];
  final authtoken;
  final userId;
  Products(this.authtoken, this.userId, this._items);
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prod) => prod.isFavourite).toList();
  }

  Future<void> fetchAndSetData([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://buily-mu-default-rtdb.firebaseio.com/products.json?auth=$authtoken&$filterString');
    try {
      var response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      url = Uri.parse(
          'https://buily-mu-default-rtdb.firebaseio.com/FavProducts/$userId.json?auth=$authtoken');
      response = await http.get(url);
      final favData = jsonDecode(response.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'] as double,
            imageUrl: prodData['imageUrl'],
            isFavourite: favData == null ? false : favData['$prodId'] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        'https://buily-mu-default-rtdb.firebaseio.com/products.json?auth=$authtoken');
    try {
      final respone = await http.post(url,
          body: json.encode({
            "title": product.title,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "description": product.description,
            "creatorId": userId,
          }));
      Product _tobeSaved = Product(
        id: json.decode(respone.body)['name'],
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        description: product.description,
      );

      _items.add(_tobeSaved);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final prod = _items.indexWhere((element) => element.id == id);
    if (prod >= 0) {
      var url = Uri.parse(
          'https://buily-mu-default-rtdb.firebaseio.com/products/$id.json?auth=$authtoken');
      await http.patch(url,
          body: json.encode({
            "title": product.title,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "description": product.description,
          }));
      _items[prod] = product;
    }

    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final exsitingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingproduct = _items[exsitingProductIndex];
    var url = Uri.parse(
        'https://buily-mu-default-rtdb.firebaseio.com/products/$id.json?auth=$authtoken');
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    final respose = await http.delete(url);
    print(respose.statusCode == null ? "null" : respose.statusCode);
    if (respose.statusCode >= 400) {
      _items.insert(exsitingProductIndex, existingproduct);
      notifyListeners();
      throw HttpException('failed to delete');
    }
    existingproduct = null;
  }
}
