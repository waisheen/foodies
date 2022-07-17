import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import 'package:foodies/star.dart';
import 'package:another_flushbar/flushbar.dart';

import 'Models/review.dart';
import 'Models/shop.dart';
import 'Services/auth.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

//OVERALL DESIGN/THEME
Color themeColour = Colors.teal;

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
PreferredSizeWidget backButton(BuildContext context, [String title = ""]) {
  return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: TextButton.icon(
        icon: const Icon(Icons.chevron_left, color: Colors.black),
        /*label: const Text(
    'Back',
    style: TextStyle(color: Colors.black),
  ),*/
        onPressed: () => Navigator.pop(context),
        label: Container(),
      ),
      title: Text(title, style: const TextStyle(color: Colors.black)));
}

//big buttons
Widget bigButton(String text, void Function()? onPressed) {
  return Container(
    height: 50.0,
    width: 320.0,
    decoration: BoxDecoration(
      color: themeColour,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: themeColour),
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
          color: color ? themeColour : Colors.white,
          border: Border.all(color: color ? Colors.black : Colors.grey)),
      height: 35,
      width: 35,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: color ? Colors.white : Colors.grey, fontSize: 12),
        ),
      ),
    ),
  );
}

//This is a widget for showing individual reviews
Widget reviewContainer(BuildContext context, Review review) {
  return Padding(
    padding: const EdgeInsets.only(top: 15),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black)),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                  padding: EdgeInsets.all(10),
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
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
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

Future<Shop?> getSellerShop() async {
  String currSellerID = AuthService().currentUser!.uid;
  QuerySnapshot snapshot = await shops.get();
  List<Shop> shopList = snapshot.docs
      .where((snapshot) => snapshot.data().toString().contains('sellerID'))
      .where((snapshot) => snapshot["sellerID"] == currSellerID)
      .map((snapshot) => Shop.fromSnapshot(snapshot))
      .toList();
  if (shopList.isNotEmpty) {
    return shopList[0];
  }
  return null;
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
  double c = (12742 * asin(sqrt(b))) * 1000;
  return c.round();
}

//colours boxes for displaying whether halal/veg
Widget dietBox(bool selected, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 2.5, right: 5),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: selected ? themeColour : Colors.white,
          border: Border.all(color: selected ? Colors.black : Colors.grey)),
      height: 35,
      width: 70,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: selected ? Colors.white : Colors.grey, fontSize: 12),
        ),
      ),
    ),
  );
}

// convert to 12hr
String convertIntToTime(int time) {
  if (time < 1200) {
    return time.toString().length == 3
        ? '${time.toString().substring(0, 1)}:${time.toString().substring(1)} A.M.'
        : '${time.toString().substring(0, 2)}:${time.toString().substring(2)} A.M.';
  }
  int afternoon = time - 1200;
  return afternoon.toString().length == 3
      ? '${afternoon.toString().substring(0, 1)}:${afternoon.toString().substring(1)} P.M.'
      : '${afternoon.toString().substring(0, 2)}:${afternoon.toString().substring(2)} P.M.';
}

bool isHalal(List<String> list) {
  return list.contains("Halal");
}

bool isVegetarian(List<String> list) {
  return list.contains("Vegetarian");
}

String getCuisine(List<String> list) {
  for (String option in list) {
    if (option == "Halal" || option == "Vegetarian") {
      continue;
    }
    return option;
  }
  return "Others";
}

Widget noShopText(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: SizedBox(
      height: MediaQuery.of(context).size.height,
      child: const Align(
        alignment: Alignment.center,
        child: Text(
          "No shop is associated with your account, contact admin",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      ),
    ),
  );
}

//displays image if link is valid
Widget showImage(String url) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Image(
      image: NetworkImage(url),
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          (url == '' ? 'No image uplaoded' : 'Image cannot be shown'),
          style: const TextStyle(fontSize: 15),
        );
      },
    ),
  );
}

Widget sliverAppBar(BuildContext context, String title) {
  return SliverAppBar(
    floating: true,
    // pinned: true,
    stretch: true,
    backgroundColor: themeColour,
    centerTitle: true,
    title: Text(title, style: const TextStyle(color: Colors.white)),
    leading: TextButton.icon(
      icon: const Icon(Icons.chevron_left, color: Colors.white),
      onPressed: () => Navigator.pop(context),
      label: Container(),
    ),
    // onStretchTrigger:
  );
}

Widget heading(BuildContext context, String field) {
  return SizedBox(
    width: MediaQuery.of(context).size.width - 60,
    child: Text(
      field,
      textAlign: TextAlign.left,
      style: TextStyle(
          color: themeColour, fontSize: 17, fontWeight: FontWeight.bold),
    ),
  );
}

void confirmationPopUp(BuildContext context, String text, Function func) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Action'),
        content: Text(text),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              // style: TextStyle(color: Colors.red)
            ),
          ),

          // The "Yes" button
          TextButton(
            onPressed: () async {
              // Close the dialog
              Navigator.of(context).pop();

              // Carry out action
              func();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

//success snack bar
void successFlushBar(BuildContext context, String message, bool bottom) {
  Flushbar(
    margin: const EdgeInsets.all(10),
    borderRadius: BorderRadius.circular(8),
    backgroundGradient: LinearGradient(colors: [
      Colors.deepPurple.shade300,
      Colors.purple.shade700,
    ]),
    duration: const Duration(seconds: 4),
    icon: const Icon(Icons.check_circle_outline_outlined, color: Colors.white),
    // mainButton: TextButton(
    //   child: const Text("Dismiss", style: TextStyle(color: Colors.white)),
    //   onPressed: () {},
    // ),
    shouldIconPulse: false,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    message: message,
    flushbarPosition: bottom ? FlushbarPosition.BOTTOM : FlushbarPosition.TOP,
  ).show(context);
}

void redFlushBar(BuildContext context, String message, bool bottom) {
  Flushbar(
    margin: const EdgeInsets.all(10),
    borderRadius: BorderRadius.circular(8),
    backgroundGradient: LinearGradient(colors: [
      Colors.red.shade600,
      Colors.red.shade300,
    ]),
    duration: const Duration(seconds: 4),
    icon: const Icon(Icons.info_outline, color: Colors.white),
    // mainButton: TextButton(
    //   child: const Text("Dismiss", style: TextStyle(color: Colors.white)),
    //   onPressed: () {},
    // ),
    shouldIconPulse: false,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    message: message,
    flushbarPosition: bottom ? FlushbarPosition.BOTTOM : FlushbarPosition.TOP,
  ).show(context);
}
