import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Promotion/createpromotionpage.dart';
import 'package:foodies/loading.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Models/promotion.dart';
import '../Models/shop.dart';
import '../Shop/shopdetails.dart';
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
  
  //variable states
  Color colour = Colors.teal;
  bool sortByStart = true;
  bool sortByEnd = false;

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
              return Padding(
                padding: const EdgeInsets.all(20),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.white,
                      title: Row(children: [
                          Text("Sort by:", style: TextStyle(fontSize: 15, color: colour),),
                          const SizedBox(width: 10),
                          sortButton("Start Date", sortByStart, () {
                            setState(() {
                              sortByStart = true;
                              sortByEnd = false;
                            });
                          }),
                          const SizedBox(width: 10),
                          sortButton("End Date", sortByEnd, () {
                            setState(() {
                              sortByStart = false;
                              sortByEnd = true;
                            });
                          }),
                        ],
                      ),
                      ),
                    SliverList(
                      delegate: SliverChildListDelegate(promoList(snapshot.data!.docs))
                      ),
                  ],
                ),
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
    
    //sort promos acc to startDate or endDate
    if (sortByStart) {
      filtered.sort((a, b) {
        if (a.startDate == b.startDate) {
          return a.endDate.compareTo(b.endDate);
        }
        return a.startDate.compareTo(b.startDate);
        });
    } else if (sortByEnd) {
      filtered.sort((a, b) {
        if (a.endDate == b.endDate) {
          return a.startDate.compareTo(b.startDate);
        }
        return a.endDate.compareTo(b.endDate);
      });
    }

    List<Widget> widgetList =
        filtered.map((promo) => promoWidget(promo)).toList();
    
    //if store has no ongoing promotions
    if (widgetList.isEmpty) {
      widgetList.add(
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.8,
          child: const Align(
            alignment: Alignment.center,
            child: Text("There are no ongoing promotions", 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
              ),
          ),
        ),
      );
    }

    widgetList.add(
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        // color: Colors.teal.shade600.withOpacity(0.5),
        elevation: 5,
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
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () async {
          //goes to shop's page
          await promo.currentShop.then((shop) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShopDetailsPage(shop: shop, showBackButton: true))));
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

  //create sort button 
  Widget sortButton(String text, bool selected, Function()? onPressed) {
    return Container(
      height: 35.0,
      decoration: BoxDecoration(
        color: selected ? colour : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colour),
      ),
      child: 
      TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: selected ? Colors.white : colour, fontSize: 13),
        ),
      ),
    );
  }

}
