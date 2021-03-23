import 'package:flutter/cupertino.dart';

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
  void toggleFavouriteStatus() {
    isFavourite = !isFavourite;
    notifyListeners();
  }
}
