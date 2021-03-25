import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isInit = false;
  bool _isLoading = true;
  @override
  void didChangeDependencies() async {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context).fetchAndSetOrder();
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ordersdata = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ordersdata.orders.length,
              itemBuilder: (context, i) => OrderItem(ordersdata.orders[i]),
            ),
    );
  }
}
