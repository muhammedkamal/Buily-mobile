import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';

import 'cart_screen.dart';

enum filters {
  favourite,
  all,
}

class ProductsOverView extends StatefulWidget {
  @override
  _ProductsOverViewState createState() => _ProductsOverViewState();
}

class _ProductsOverViewState extends State<ProductsOverView> {
  bool _showOnlyFavourite = false;
  bool _isInit = false;
  bool _isLoading = true;
  @override
  void didChangeDependencies() async {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Products>(context).fetchAndSetData();
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buily Products'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Favourites'),
                value: filters.favourite,
              ),
              PopupMenuItem(
                child: Text('All Products'),
                value: filters.all,
              ),
            ],
            icon: Icon(Icons.more_vert),
            onSelected: (filters selectedFilter) {
              setState(() {
                if (selectedFilter == filters.favourite) {
                  _showOnlyFavourite = true;
                } else {
                  _showOnlyFavourite = false;
                }
              });
            },
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemsCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavourite),
    );
  }
}
