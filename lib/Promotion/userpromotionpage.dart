import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/loading.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Features/shopdetails.dart';
import '../Models/promotion.dart';
import '../Models/shop.dart';

class UserPromotionPage extends StatefulWidget {
  const UserPromotionPage({Key? key}) : super(key: key);

  @override
  State<UserPromotionPage> createState() => _UserPromotionPageState();
}

class _UserPromotionPageState extends State<UserPromotionPage> {
  final CollectionReference promotions =
      FirebaseFirestore.instance.collection("Promotion");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: promotions.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Loading();
              }
              return ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: promoList(snapshot.data!.docs),
              );
            }));
  }

  List<Widget> promoList(List<QueryDocumentSnapshot<Object?>> docsList) {
    List filtered = docsList
        //map each document to Promotion
        .map((document) => Promotion.fromSnapshot(document))
        .toList();
    // .where((promo) => promo.endDate.isAfter(DateTime.now())).toList();  //uncomment to view current promos

    //sort promos acc to startDate
    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));

    return filtered.map((promo) => promoWidget(promo)).toList();
  }

  //build widget layout for each promo
  Widget promoWidget(Promotion promo) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () async {
          //goes to shop's page
          await promo.currentShop.then((shop) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShopDetailsPage(shop: shop))));
        },
        splashColor: Colors.teal.shade600.withOpacity(0.5),
        child: Ink(
          child: Column(
            children: <Widget>[
              Image(
                image: NetworkImage(promo.imageURL),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                // fit: BoxFit.fill,
                // errorBuilder: (context, error, stackTrace) {
                //   return const Text(
                //     'Whoops!',
                //     style: TextStyle(fontSize: 30, color: Colors.red),
                //   );
                // },
              ),
              emptyBox(5),
              ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(promo.details),
                  ),
                  subtitle: //Text("${dateFromDateTime(promo.startDate)} ~ ${dateFromDateTime(promo.endDate)} \n\n 📍  location"),
                      dateAndShopText(context, promo)),
              emptyBox(10),
            ],
          ),
        ),
      ),
    );
  }

  String dateFromDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  Widget dateAndShopText(BuildContext context, Promotion promo) {
    return FutureBuilder(
        future: promo.currentShop,
        builder: (context, AsyncSnapshot<Shop> shop) {
          if (!shop.hasData) {
            return const Loading();
          }
          return Text(
              "${dateFromDateTime(promo.startDate)} ~ ${dateFromDateTime(promo.endDate)} \n\n 📍  ${shop.data!.name}");
        });
  }
}
