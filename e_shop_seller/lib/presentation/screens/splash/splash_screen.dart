import 'package:flutter/material.dart';

import '../../../utils/size_config.dart';
import 'components/body.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
    );
  }
}

/*
Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_grocery_store_sharp,
            color: Colors.blueAccent,
            size: 120,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "e ",
                style: TextStyle(color: Colors.black54, fontSize: 24),
              ),
              Text(
                "Shop ",
                style: TextStyle(color: Colors.blueAccent, fontSize: 24),
              ),
              Text(
                "Seller",
                style: TextStyle(color: Colors.black54, fontSize: 24),
              ),
            ],
          ),
        ],
      ),

    */
