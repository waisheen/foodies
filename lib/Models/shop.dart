import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Models/foodplace.dart';
import 'package:foodies/reusablewidgets.dart';
import 'package:foodies/star.dart';

class Shop {
  String uid;
  String name;
  int minPrice;
  int maxPrice;
  int closing;
  int opening;
  List<String> openDays;
  String imageURL;
  String foodPlace;
  static List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String? sellerID;
  double totalRating;
  double totalReview;
  static List<String> allOptions = [
    'Halal',
    'Vegetarian',
    'Western',
    'Chinese',
    'Thai',
    'Korean',
    'Japanese',
    'Soup',
    'Fast Food',
    'Drinks',
    'Dessert',
    'Snack',
    'Indian',
    'Alcohol',
    'Dim Sum'
  ];
  List<String> options;

  //Initializer
  Shop(
      this.uid,
      this.name,
      this.minPrice,
      this.maxPrice,
      this.closing,
      this.opening,
      this.openDays,
      this.imageURL,
      this.foodPlace,
      this.sellerID,
      this.totalReview,
      this.options,
      this.totalRating);

  //Creating Shop object from a snapshot
  Shop.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        name = snapshot['name'],
        minPrice = snapshot['minPrice'],
        maxPrice = snapshot['maxPrice'],
        closing = snapshot['closing'],
        opening = snapshot['opening'],
        openDays = List<String>.from(snapshot['openDays']),
        imageURL = snapshot['imageURL'],
        foodPlace = snapshot['foodPlace'],
        sellerID = snapshot.data().toString().contains('sellerID')
            ? snapshot['sellerID']
            : null,
        options = List<String>.from(snapshot['options']),
        totalReview = snapshot['totalReview'] + 0.0,
        totalRating = snapshot['totalRating'] + 0.0;

  //String representation of open days
  Widget getDaysText(BuildContext context) {
    return Row(
        children: allDays
            .map((day) =>
                colorBox(context, openDays.contains(day), day.substring(0, 3)))
            .toList());
  }

  //Get foodplace
  Future<FoodPlace> get currentFoodPlace async {
    FoodPlace currentFoodPlace = FoodPlace.fromSnapshot(await FirebaseFirestore
        .instance
        .collection('FoodPlace')
        .doc(foodPlace)
        .get());
    return currentFoodPlace;
  }

  //Get foodplace in form of text widget
  Widget foodPlaceText(BuildContext context, double size) {
    return FutureBuilder(
        future: currentFoodPlace,
        builder: (context, AsyncSnapshot<FoodPlace> newFoodPlace) {
          if (!newFoodPlace.hasData) {
            return const Text('Loading...');
          }
          return Text(
            "📍 ${newFoodPlace.data!.name}",
            style: TextStyle(fontSize: size, color: Colors.grey.shade600),
          );
        });
  }

  //Show average stars
  double get averageRating {
    return totalReview == 0 ? 0 : totalRating / totalReview;
  }

  //Show number of stars
  Widget showRatings(BuildContext context) {
    if (totalReview == 0) {
      return const Text('No reviews yet!');
    }
    return StarRating(
      rating: totalRating / totalReview,
      onRatingChanged: (ratings) {},
      tappable: false,
    );
  }

  //get operating hours
  String get operatingHours {
    return '${convertIntToTime(opening)} to ${convertIntToTime(closing)}';
  }
}
