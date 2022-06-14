import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Models/shop.dart';

import '../loading.dart';

class Promotion {
  String details;
  DateTime startDate;
  DateTime endDate;
  String imageURL;
  Future<dynamic> shop;

  //Initializer
  Promotion(this.details, this.startDate, this.endDate, this.imageURL, this.shop);

  //Creating Shop object from a snapshot
  Promotion.fromSnapshot(DocumentSnapshot snapshot)
      : details = snapshot['details'],
        startDate = snapshot['startDate'],
        endDate = snapshot['endDate'],
        imageURL = snapshot['imageURL'],
        shop = snapshot['shop'].get();

  //Get shop object
  Future<Shop> get currentShop async {
    DocumentSnapshot doc = await shop;
    Shop currentShop = Shop.fromSnapshot(doc);
    return currentShop;
  }

}
