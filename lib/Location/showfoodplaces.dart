import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Models/nus_location.dart';
import 'package:foodies/loading.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Models/foodplace.dart';

class FoodPlacesPage extends StatefulWidget {
  const FoodPlacesPage({Key? key, required this.location}) : super(key: key);
  final NUSLocation location;

  @override
  State<FoodPlacesPage> createState() => _FoodPlacesPageState();
}

class _FoodPlacesPageState extends State<FoodPlacesPage> {
  //Stream of foodplaces at location
  Stream<QuerySnapshot> getFoodPlaceSnapshots() async* {
    yield* FirebaseFirestore.instance
        .collection('FoodPlace')
        .where('location', isEqualTo: widget.location.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: getFoodPlaceSnapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Loading();
              }
              return ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: getFoodPlaces(snapshot.data!.docs),
              );
            }));
  }

  List<Widget> getFoodPlaces(List<QueryDocumentSnapshot> docs) {
    List<FoodPlace> filtered =
        docs.map((document) => FoodPlace.fromSnapshot(document)).toList();
    return filtered.map((promo) => foodPlaceCard(promo)).toList();
  }

  //build widget layout for each promo
  Widget foodPlaceCard(FoodPlace foodplace) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          //show all shops at foodplace
        },
        splashColor: Colors.teal.shade600.withOpacity(0.5),
        child: Ink(
          child: Column(
            children: <Widget>[
              Image(
                image: NetworkImage(foodplace.imageURL),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              emptyBox(5),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(foodplace.name),
                ),
                subtitle: Text(widget.location.name),
              ),
              emptyBox(10),
            ],
          ),
        ),
      ),
    );
  }
}
