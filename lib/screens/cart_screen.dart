import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';

import '../widgets/cart_item.dart' as w;

class CartScreen extends StatelessWidget {
  static String routeName = "/cartScreen";
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: themeData.primaryTextTheme.headline6.color),
                    ),
                    backgroundColor: themeData.primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => w.CartItem(
                  id: cart.items.values.toList()[i].id,
                  productId: cart.items.keys.toList()[i],
                  price: cart.items.values.toList()[i].price,
                  quantity: cart.items.values.toList()[i].quantity,
                  title: cart.items.values.toList()[i].title),
              itemCount: cart.itemsCount,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    @required this.cart,
  });

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isplacing = false;
  Future<void> addOrder() async {
    {
      setState(() {
        _isplacing = true;
      });
      try {
        await Provider.of<Orders>(context, listen: false).addOrder(
          widget.cart.items.values.toList(),
          widget.cart.totalAmount,
        );
        widget.cart.clearCart();
      } catch (_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text('An error has ocured please try again later'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Okay'),
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isplacing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isplacing
        ? Center(child: CircularProgressIndicator())
        : TextButton(
            onPressed: widget.cart.totalAmount <= 0 ? null : () => addOrder(),
            child: Text('Order Now'),
          );
  }
}
