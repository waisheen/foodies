import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Shop/shopdetails.dart';

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
    yield* FirebaseFirestore.instance.collection('Shop').limit(4).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Container(
            alignment: Alignment.topLeft,
            child: Row(
              children: const [
                Icon(
                  Icons.star_outline,
                  color: Colors.orange,
                ),
                SizedBox(width: 5),
                Text(
                  'Highest Ratings',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
            height: 265,
            child: buildShopStream(
                context, getShopSnapshots(context), ratingList)),
        emptyBox(20),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Container(
            alignment: Alignment.topLeft,
            child: Row(
              children: const [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),
                SizedBox(width: 5),
                Text(
                  'Most Popular',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
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
  return SizedBox(
    width: 200,
    child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTapped,
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 200,
                child: Image(
                  image: NetworkImage(shop.imageURL),
                  height: 150,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    //placeholder picture in the case image cannot be displayed
                    return const Image(
                      image: AssetImage('assets/images/logo5.png'),
                      height: 150,
                      width: 200,
                      fit: BoxFit.contain
                    );
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: ListTile(
                    title: Text(
                      shop.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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
          ),
        )),
  );
}

//This collects info from shop database and builds a card
Widget buildShopStream(
    BuildContext context,
    Stream<QuerySnapshot> stream,
    List<Widget> Function(List<QueryDocumentSnapshot>, BuildContext context)
        function) {
  return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Loading();
        }
        return ListView(
            shrinkWrap: true,
            /*physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),*/
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
                    builder: (context) =>
                        ShopDetailsPage(shop: shop, showBackButton: true))),
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
                    builder: (context) =>
                        ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}
