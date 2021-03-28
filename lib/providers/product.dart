import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id, title, description, imageUrl;
  final double price;
  bool isFavourite;
  Product({
    @required this.id,
    @required this.title,
    this.description,
    this.imageUrl,
    @required this.price,
    this.isFavourite = false,
  });
  Future<void> toggleFavouriteStatus(String authtoken, String userId) async {
    isFavourite = !isFavourite;
    notifyListeners();
    var url = Uri.parse(
        'https://buily-mu-default-rtdb.firebaseio.com/FavProducts/$userId.json?auth=$authtoken');
    try {
      final resposne = await http.put(url,
          body: json.encode({
            "$id": isFavourite,
          }));
      if (resposne.statusCode >= 400) {
        isFavourite = !isFavourite;
        notifyListeners();
      }
    } catch (error) {
      isFavourite = !isFavourite;
      notifyListeners();
    }
  }
}
