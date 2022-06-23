import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Models/foodplace.dart';
import 'package:foodies/Models/review.dart';
import 'package:foodies/reusablewidgets.dart';
import 'package:foodies/star.dart';

import '../loading.dart';

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
  List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String sellerID;
  double totalRating;
  double totalReview;
  List<String> options;

  List<String> cuisineList = [
    'Chinese',
    'Malay',
    'Indian',
    'Western',
    'Japanese',
    'Korean',
    'Drinks',
    'Others'
  ];

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
    this.totalRating,
    this.options,
  );

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
        sellerID = snapshot['sellerID'],
        totalReview = snapshot['totalReview'] + 0.0,
        totalRating = snapshot['totalRating'] + 0.0,
        options = List<String>.from(snapshot['options']);

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
            return const Loading();
          }
          return Text(
            "📍 ${newFoodPlace.data!.name}",
            style: TextStyle(fontSize: size),
          );
        });
  }

  //Get reviews stream
  Stream<QuerySnapshot> get shopReviews async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: uid)
        .snapshots();
  }

  //Show average stars
  double get averageRating {
    return totalReview == 0 ? 0 : totalRating / totalReview;
  }

  //Show number of stars
  Widget showRatings(BuildContext context) {
    return StreamBuilder(
        stream: shopReviews,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...');
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Text('No reviews yet!');
          }
          List<Review> reviews = snapshot.data!.docs
              .map((doc) => Review.fromSnapshot(doc))
              .toList();
          double ratings = 0;
          double count = 0;
          for (var element in reviews) {
            ratings += element.rating;
            count += 1;
          }
          return StarRating(
              rating: ratings / count, onRatingChanged: (ratings) {});
        });
  }

  //get operating hours
  String get operatingHours {
    return '${convertIntToTime(opening)} to ${convertIntToTime(closing)}';
  }

}
