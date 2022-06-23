import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import 'package:foodies/star.dart';

import 'Models/review.dart';
import 'Models/shop.dart';
import 'Services/auth.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

CollectionReference shops = FirebaseFirestore.instance.collection("Shop");

Widget emptyBox(double height) {
  return SizedBox(height: height);
}

//user to input text field
Widget inputText(String label, String hint, Widget icon,
    String? Function(String?)? validator, void Function(String)? onChanged,
    [String? initial]) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0),
    child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelText: label,
          hintText: hint,
          prefixIcon: icon,
        ),
        initialValue: initial,
        validator: validator,
        onChanged: onChanged),
  );
}

//user to input text field (obscured)
Widget inputObscuredText(String label, String hint, Widget icon,
    String? Function(String?)? validator, void Function(String)? onChanged,
    [String? initial]) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0),
    child: TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelText: label,
        hintText: hint,
        prefixIcon: icon,
      ),
      validator: validator,
      onChanged: onChanged,
      obscureText: true,
    ),
  );
}

//back button
PreferredSizeWidget backButton(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: TextButton.icon(
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
      /*label: const Text(
    'Back',
    style: TextStyle(color: Colors.black),
  ),*/
      onPressed: () => Navigator.pop(context),
      label: Container(),
    ),
  );
}

//big buttons
Widget bigButton(String text, void Function()? onPressed) {
  return Container(
    height: 50.0,
    width: 320.0,
    decoration: BoxDecoration(
      color: Colors.teal,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.teal),
    ),
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );
}

//futurebuilders to listen to changes
Widget futureText(BuildContext context, CollectionReference users, String uid,
    String getter) {
  return FutureBuilder(
      future: users.doc(uid).get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String text = snapshot.data!.get(getter).toString();
          return Text(
            text,
            style: const TextStyle(fontSize: 16),
          );
        }
        return const Text(
          'Loading...',
          style: TextStyle(fontSize: 16),
        );
      });
}

//Build colored boxes
Widget colorBox(BuildContext context, bool color, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 2.5, right: 5),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: color ? Colors.green : Colors.white,
          border: Border.all(color: Colors.black)),
      height: 35,
      width: 35,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
    ),
  );
}

//This is a widget for showing individual reviews
Widget reviewContainer(BuildContext context, Review review) {
  return Padding(
    padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black)),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                  padding: EdgeInsets.only(left: 5, top: 5),
                  child: Icon(Icons.account_circle_rounded)),
              review.userText(context),
            ],
          ),
          emptyBox(10),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child:
                StarRating(rating: review.rating, onRatingChanged: (rating) {}),
          ),
          emptyBox(20),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: SizedBox(
              width: 350,
              child: Text(
                review.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          emptyBox(20),
        ],
      ),
    ),
  );
}

Future<Shop> getSellerShop() async {
  String currSellerID = AuthService().currentUser!.uid;
  QuerySnapshot snapshot = await shops.get();
  List<Shop> shopList = snapshot.docs
      .where((snapshot) => snapshot["sellerID"] == currSellerID)
      .map((snapshot) => Shop.fromSnapshot(snapshot))
      .toList();
  return shopList[0];
}

//get only date portion of DateTime
String dateFromDateTime(DateTime dateTime) {
  return "${dateTime.day} ${DateFormat('MMM').format(dateTime)} ${dateTime.year}";
}

//Calculate Distance
int distance(lat1, lon1, lat2, lon2) {
  double a = 0.017453292519943295;
  double b = 0.5 -
      cos((lat2 - lat1) * a) / 2 +
      cos(lat1 * a) * cos(lat2 * a) * (1 - cos((lon2 - lon1) * a)) / 2;
  return 12742 * asin(sqrt(b)).round();
}
