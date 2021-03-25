import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_details.dart';

class ProductGridItem extends StatelessWidget {
/*   final String id, title, imageUrl;
  ProductGridItem({this.id, this.title, this.imageUrl}); */
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
        },
        child: Card(
          elevation: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GridTile(
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
                footer: GridTileBar(
                  title: Text(
                    product.title,
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.black87,
                  leading: Consumer<Product>(
                    builder: (ctx, product, child) => IconButton(
                      icon: Icon(product.isFavourite
                          ? Icons.favorite
                          : Icons.favorite_border),
                      onPressed: () {
                        product.toggleFavouriteStatus();
                      },
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  trailing: Consumer<Cart>(
                    builder: (_, cart, ch) => IconButton(
                      icon: ch,
                      onPressed: () {
                        cart.addItem(
                          productId: product.id,
                          title: product.title,
                          price: product.price,
                        );
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item added to Cart!'),
                            duration: Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                cart.removeSingleItem(product.id);
                              },
                            ),
                          ),
                        );
                      },
                      color: Theme.of(context).accentColor,
                    ),
                    child: Icon(Icons.shopping_cart),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
