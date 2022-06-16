import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Features/shopdetails.dart';
import 'package:foodies/star.dart';

import 'Models/review.dart';
import 'Models/shop.dart';
import 'loading.dart';

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
          border: const OutlineInputBorder(),
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
        border: const OutlineInputBorder(),
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
    width: 250.0,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.teal),
    ),
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16),
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

//Builds a card with a title, image and a onTap fuction
Widget buildCard(BuildContext context, String title, String imageURL,
    void Function() onTapped) {
  return Card(
      child: InkWell(
          onTap: onTapped,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 500,
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 30.0),
                  textAlign: TextAlign.left,
                ),
              ),
              Image.network(imageURL),
            ],
          )));
}

//This collects info from shop database and builds a card
Widget buildShopStream(BuildContext context, Stream<QuerySnapshot> stream) {
  return Flexible(
      fit: FlexFit.loose,
      child: StreamBuilder(
          stream: stream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Loading();
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  Shop shop = Shop.fromSnapshot(snapshot.data!.docs[index]);
                  return buildCard(
                    context,
                    shop.name,
                    shop.imageURL,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShopDetailsPage(shop: shop))),
                  );
                });
          }));
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
          SizedBox(
              width: 350,
              child: Text(review.description,
                  style: const TextStyle(fontSize: 14))),
          emptyBox(20),
        ],
      ),
    ),
  );
}

//This widget displays all reviews
Widget buildReviewStream(
    BuildContext context, Stream<QuerySnapshot> stream, String shopID) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Flexible(
          fit: FlexFit.loose,
          child: StreamBuilder(
              stream: stream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Loading();
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Text('No Reviews Yet!');
                }
                return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      Review review =
                          Review.fromSnapshot(snapshot.data!.docs[index]);
                      return reviewContainer(
                        context,
                        review,
                      );
                    });
              })),
    ],
  );
}
