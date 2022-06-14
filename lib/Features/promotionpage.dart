import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/loading.dart';

import '../Models/promotion.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({Key? key}) : super(key: key);

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  final CollectionReference promotions = FirebaseFirestore.instance.collection("Promotion");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: promotions.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: snapshot.data!.docs.map((document) {
              Promotion promo = Promotion.fromSnapshot(document);
              return Text(promo.details);
            }).toList(),
          );
        }
        )
    );
  }

  //build widget layout for each promo
  Widget promoWidget(QueryDocumentSnapshot document) {
    return Column(
        children: <Widget>[ 
          Image(
            image: NetworkImage(document["imageURL"]),
            height: 50.0,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ],
      );
  }
}
