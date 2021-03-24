import 'dart:convert';

import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
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
    )
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prod) => prod.isFavourite).toList();
  }

  Future<void> fetchAndSetData() async {
    var url =
        Uri.parse('https://buily-mu-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    var url =
        Uri.parse('https://buily-mu-default-rtdb.firebaseio.com/products.json');
    try {
      final respone = await http.post(url,
          body: json.encode({
            "title": product.title,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "description": product.description,
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

  void updateProduct(String id, Product product) {
    final prod = _items.indexWhere((element) => element.id == id);
    _items[prod] = product;
    notifyListeners();
  }

  void deleteProduct(String id) {
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
