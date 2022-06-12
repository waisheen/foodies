import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Models/foodplace.dart';

import '../loading.dart';

class Shop {
  String name;
  int minPrice;
  int maxPrice;
  int closing;
  int opening;
  List<String> openDays;
  String imageURL;
  Future<dynamic> foodPlace;

  //Initializer
  Shop(this.name, this.minPrice, this.maxPrice, this.closing, this.opening,
      this.openDays, this.imageURL, this.foodPlace);

  //Creating Shop object from a snapshot
  Shop.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        minPrice = snapshot['minPrice'],
        maxPrice = snapshot['maxPrice'],
        closing = snapshot['closing'],
        opening = snapshot['opening'],
        openDays = List<String>.from(snapshot['openDays']),
        imageURL = snapshot['imageURL'],
        foodPlace = snapshot['foodPlace'].get();

  //String representation of open days
  Widget getDaysText() {
    return Row(children: openDays.map((day) => Text(day)).toList());
  }

  //Get foodplace
  Future<FoodPlace> get currentFoodPlace async {
    DocumentSnapshot doc = await foodPlace;
    FoodPlace currentFoodPlace = FoodPlace.fromSnapshot(doc);
    return currentFoodPlace;
  }

  //Get foodplace in form of text widget
  Widget foodPlaceText(BuildContext context) {
    return FutureBuilder(
        future: currentFoodPlace,
        builder: (context, AsyncSnapshot<FoodPlace> newFoodPlace) {
          if (!newFoodPlace.hasData) {
            return const Loading();
          }
          return Text(
            newFoodPlace.data!.name,
            style: const TextStyle(fontSize: 16),
          );
        });
  }

  //Check whether shop is open

}
