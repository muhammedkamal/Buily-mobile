import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> cartItems;
  final DateTime dateTime;
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.cartItems,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final authtoken;
  final userId;
  Orders(this.authtoken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    var url = Uri.parse(
        'https://buily-mu-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authtoken');
    try {
      final resopnse = await http.post(url,
          body: json.encode({
            'amount': total,
            'timeStamp': DateTime.now().toIso8601String(),
            'products': products
                .map((p) => {
                      'id': p.id,
                      'price': p.price,
                      'quantity': p.quantity,
                      'title': p.title,
                    })
                .toList()
          }));
      if (resopnse.statusCode < 400) {
        _orders.insert(
          0,
          OrderItem(
            id: json.decode(resopnse.body)['name'],
            amount: total,
            cartItems: products,
            dateTime: DateTime.now(),
          ),
        );
        notifyListeners();
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetOrder() async {
    var url = Uri.parse(
        'https://buily-mu-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authtoken');
    try {
      final response = await http.get(url);
      //print(response.body);
      final extractedDate = jsonDecode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedProducts = [];
      if (extractedDate == null) return;
      extractedDate.forEach((orderId, orderData) {
        loadedProducts.add(OrderItem(
            id: orderId,
            amount: orderData["amount"],
            cartItems: (orderData['products'] as List<dynamic>)
                .map(
                  (e) => CartItem(
                    id: e['id'],
                    price: e['price'] as double,
                    quantity: e['quantity'],
                    title: e['title'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(orderData["timeStamp"])));
      });
      _orders = loadedProducts;
      notifyListeners();
    } catch (error) {}
  }
}
