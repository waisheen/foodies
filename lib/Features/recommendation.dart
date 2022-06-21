import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Features/shopdetails.dart';

import '../Models/shop.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  //This collect all shops available, can be further filtered
  Stream<QuerySnapshot> getShopSnapshots(BuildContext context) async* {
    yield* FirebaseFirestore.instance.collection('Shop').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Highest ratings'),
        SizedBox(
            height: 265,
            child: buildShopStream(
                context, getShopSnapshots(context), ratingList)),
        emptyBox(20),
        const Text('Most reviewed'),
        SizedBox(
            height: 265,
            child: buildShopStream(
                context, getShopSnapshots(context), numberList)),
      ],
    );
  }
}

//Builds a card with a title, image and a onTap fuction
Widget buildCard(BuildContext context, Shop shop, void Function() onTapped) {
  return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
          onTap: onTapped,
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image(
                image: NetworkImage(shop.imageURL),
                height: 150,
                width: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  //placeholder picture in the case image cannot be displayed
                  return const Image(
                    image: AssetImage('assets/images/logo3.png'),
                  );
                },
              ),
              
              SizedBox(
                width: 220,
                child: ListTile(
                  title: Text(shop.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: shop.foodPlaceText(context, 14)),
              ),

              Row(
                children: [
                  shop.showRatings(context),
                  Container(
                    width: 5,
                  ),
                  Text('${shop.averageRating.toStringAsFixed(1)}/5.0')
                ],
              ),
            ],
          )));
}

//This collects info from shop database and builds a card
Widget buildShopStream(
    BuildContext context,
    Stream<QuerySnapshot> stream,
    List<Widget> Function(List<QueryDocumentSnapshot>, BuildContext context) function) {
  return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Loading();
        }
        return ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
            scrollDirection: Axis.horizontal,
            children: function(snapshot.data!.docs, context));
      });
}

//This sorts shops by ratings
List<Widget> ratingList(
    List<QueryDocumentSnapshot> docsList, BuildContext context) {
  List<Shop> filtered =
      docsList.map((document) => Shop.fromSnapshot(document)).toList();

  //sort shops acc to ratings
  filtered.sort((shop1, shop2) {
    double rating1 = shop1.averageRating;
    double rating2 = shop2.averageRating;
    if (rating1 - rating2 > 0) {
      return -1;
    }
    return 1;
  });
  List<Widget> widgetList = filtered
      .map((shop) => buildCard(
            context,
            shop,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}

//This sorts shops by number of reviews
List<Widget> numberList(
    List<QueryDocumentSnapshot> docsList, BuildContext context) {
  List<Shop> filtered =
      docsList.map((document) => Shop.fromSnapshot(document)).toList();

  //sort shops acc to number of reviews
  filtered.sort((shop1, shop2) {
    double rating1 = shop1.totalReview;
    double rating2 = shop2.totalReview;
    if (rating1 - rating2 > 0) {
      return -1;
    }
    return 1;
  });
  List<Widget> widgetList = filtered
      .map((shop) => buildCard(
            context,
            shop,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}
