import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/loading.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Shop/shopdetails.dart';
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

  List<Widget> promoList(List<QueryDocumentSnapshot<Object?>> docsList) {
    List filtered = docsList
        //map each document to Promotion
        .map((document) => Promotion.fromSnapshot(document))
        .toList();
    // .where((promo) => promo.endDate.isAfter(DateTime.now())).toList();  //uncomment to view current promos

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

    List<Widget> widgetList = filtered.map((promo) => promoWidget(promo)).toList();

    //if widgetList is empty i.e. there are no promotions
    if (widgetList.isEmpty) {
      widgetList.add(
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.6,
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
