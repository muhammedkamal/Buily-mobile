import 'dart:math';

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 5.0),
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
              transform: Matrix4.rotationZ(-10 * pi / 180)
                ..translate(-23.0, 7.0),
              // ..translate(-10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.deepOrange.shade900,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                'Buily',
                style: TextStyle(
                  color: Theme.of(context).accentTextTheme.headline6.color,
                  fontSize: 50,
                  fontFamily: 'Anton',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
        Center(child: Text('Loading ...'))
      ],
    ));
  }
}
