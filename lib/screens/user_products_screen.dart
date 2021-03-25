import 'package:flutter/material.dart';
import 'package:market_app/providers/products_provider.dart';
import 'package:market_app/screens/edit_product_screen.dart';
import 'package:market_app/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/userProducts";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              }),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<Products>(context, listen: false).fetchAndSetData();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Consumer<Products>(
            builder: (_, products, ch) => ListView.builder(
              itemBuilder: (_, i) => Column(
                children: [
                  UserProductItem(products.items[i].id),
                  Divider(),
                ],
              ),
              itemCount: products.items.length,
            ),
          ),
        ),
      ),
    );
  }
}
