import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/loading.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Shop/shopdetails.dart';
import '../Models/foodplace.dart';
import '../Models/shop.dart';

class ShowShopsPage extends StatefulWidget {
  const ShowShopsPage({Key? key, required this.foodPlace}) : super(key: key);
  final FoodPlace foodPlace;

  @override
  State<ShowShopsPage> createState() => _ShowShopsPageState();
}

class _ShowShopsPageState extends State<ShowShopsPage> {
  //Stream of shops at foodplaces
  Stream<QuerySnapshot> getShopSnapshots() async* {
    yield* FirebaseFirestore.instance
        .collection('Shop')
        .where('foodPlace', isEqualTo: widget.foodPlace.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: backButton(context, "Stores"),
        body: StreamBuilder(
            stream: getShopSnapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Loading();
              }
              return ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: getShops(snapshot.data!.docs),
              );
            }));
  }

  List<Widget> getShops(List<QueryDocumentSnapshot> docs) {
    List<Shop> filtered =
        docs.map((document) => Shop.fromSnapshot(document)).toList();
    return filtered.map((shop) => shopCard(shop)).toList();
  }

  //build widget layout for each shop
  Widget shopCard(Shop shop) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ShopDetailsPage(shop: shop, showBackButton: true))),
        splashColor: themeColour.withOpacity(0.5),
        child: Ink(
          child: Column(
            children: <Widget>[
              Image(
                image: NetworkImage(shop.imageURL),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              emptyBox(5),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(shop.name),
                ),
                subtitle: Text(shop.operatingHours),
              ),
              emptyBox(10),
            ],
          ),
        ),
      ),
    );
  }
}
