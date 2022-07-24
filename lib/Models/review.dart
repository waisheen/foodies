import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'shop.dart';

class Review {
  String uid;
  String description;
  double rating;
  String shop;
  String user;

  //Initializer
  Review(this.uid, this.description, this.rating, this.shop, this.user);

  //Creating Review object from a snapshot
  Review.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        description = snapshot['description'],
        rating = snapshot['rating'] + .0,
        shop = snapshot['shop'],
        user = snapshot['user'];

  //Get Shop object
  Future<Shop> get currentShop async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('Shop').doc(shop).get();
    Shop currentShop = Shop.fromSnapshot(doc);
    return currentShop;
  }

  //Get user's name in form of text widget
  Widget userText(BuildContext context) {
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('UserInfo').doc(user).get(),
        builder: (context, AsyncSnapshot newUser) {
          if (!newUser.hasData) {
            return const Text('Loading...');
          }
          return Text(
            newUser.data!.get('name'),
            style: const TextStyle(fontSize: 15),
          );
        });
  }
}
