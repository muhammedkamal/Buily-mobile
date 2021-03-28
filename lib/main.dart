import 'package:flutter/material.dart';
import 'package:market_app/providers/auth.dart';

import 'package:provider/provider.dart';

import 'screens/cart_screen.dart';
import './screens/product_details.dart';
import './screens/product_overview.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/splash_screen.dart';
import './screens/auth_screen.dart';

import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(null, null, []),
          update: (ctx, auth, prevOrders) => Orders(auth.token, auth.userId,
              prevOrders == null ? [] : prevOrders.orders),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(null, null, []),
          update: (ctx, auth, previousProduct) => Products(
              auth.token,
              auth.userId,
              previousProduct == null ? [] : previousProduct.items),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, authData, _) => MaterialApp(
          title: 'Buily',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.deepOrangeAccent,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Lato',
          ),
          home: authData.isAuth()
              ? ProductsOverView()
              : FutureBuilder(
                  future: authData.tryLogIn(),
                  builder: (ctx, snapShotData) =>
                      snapShotData.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
