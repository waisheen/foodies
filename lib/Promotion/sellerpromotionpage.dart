import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Promotion/createpromotionpage.dart';
import 'package:foodies/loading.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Models/promotion.dart';
import '../Models/shop.dart';
import '../Features/shopdetails.dart';
import '../Services/auth.dart';

class SellerPromotionPage extends StatefulWidget {
  const SellerPromotionPage({Key? key, required this.shop}) : super(key: key);
  final Shop? shop;

  @override
  State<SellerPromotionPage> createState() => _SellerPromotionPageState();
}

class _SellerPromotionPageState extends State<SellerPromotionPage> {
  final AuthService _auth = AuthService();
  final CollectionReference promotions =
      FirebaseFirestore.instance.collection("Promotion");
  final CollectionReference shops =
      FirebaseFirestore.instance.collection("Shop");

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

  //creates a list of promo widgets
  List<Widget> promoList(List<QueryDocumentSnapshot<Object?>> docsList) {
    List filtered = docsList
        //map each document to Promotion
        .map((document) => Promotion.fromSnapshot(document))
        //uncomment to view current promos
        // .where((promo) => promo.endDate.isAfter(DateTime.now())).toList();
        //only show seller's promos
        .where((promo) => promo.shop_id == widget.shop!.uid)
        .toList();
    //sort promos acc to startDate
    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));

    List<Widget> widgetList =
        filtered.map((promo) => promoWidget(promo)).toList();
    widgetList.add(
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        // color: Colors.teal.shade600.withOpacity(0.5),
        elevation: 20,
        child: bigButton(
          "Create New Promotion",
          () async {
            //goes to create promotion page
            await getSellerShop().then((shop) => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreatePromotionPage(shop: shop))));
          },
        ),
      ),
    );
    return widgetList;
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
                errorBuilder: (context, error, stackTrace) {
                  //placeholder picture in the case image cannot be displayed
                  return const Image(
                    image: AssetImage('assets/images/logo3.png'),
                  );
                },
              ),
              
              emptyBox(5),
              
              ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(promo.details),
                  ),
                  subtitle: dateAndShopText(context, promo)),
              
              emptyBox(10),
              
              Container(
                height: 35.0,
                width: 300.0,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red),
                ),
                child: TextButton(
                  onPressed: () async {
                    //goes to create promotion page
                    await getSellerShop().then((shop) => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CreatePromotionPage(shop: shop, promo: promo))));
                  },
                  child: const Text(
                    "Edit Promotion",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              
              emptyBox(10),
            ],
          ),
        ),
      ),
    );
  }

  Widget dateAndShopText(BuildContext context, Promotion promo) {
    return FutureBuilder(
        future: promo.currentShop,
        builder: (context, AsyncSnapshot<Shop> shop) {
          if (!shop.hasData) {
            return const Loading();
          }
          return Text(
              "${dateFromDateTime(promo.startDate)} - ${dateFromDateTime(promo.endDate)} \n\n 📍  ${shop.data!.name}");
        });
  }

  //returns the current user(seller)'s shop
  Future<Shop> getSellerShop() async {
    String currSellerID = _auth.currentUser!.uid;
    QuerySnapshot snapshot = await shops.get();
    List<Shop> shopList = snapshot.docs
        .where((snapshot) => snapshot["sellerID"] == currSellerID)
        .map((snapshot) => Shop.fromSnapshot(snapshot))
        .toList();
    return shopList[0];
  }
}
