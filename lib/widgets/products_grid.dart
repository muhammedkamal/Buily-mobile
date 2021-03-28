import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavourite;
  ProductsGrid(this.showOnlyFavourite);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showOnlyFavourite ? productsData.favItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          value: products[index],
          child: Hero(
            tag: products[index].id,
            child: ProductGridItem(
                /* id: products[index].id,
              title: products[index].title,
              imageUrl: products[index].imageUrl, */
                ),
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
    );
  }
}
