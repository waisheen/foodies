import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodies/Models/shop.dart';

class Promotion {
  String uid;
  String details;
  DateTime startDate;
  DateTime endDate;
  String imageURL;
  Future<dynamic> shop;

  //Initializer
  Promotion(this.uid, this.details, this.startDate, this.endDate, this.imageURL, this.shop);

  //Creating Shop object from a snapshot
  Promotion.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        details = snapshot['details'],
        startDate = DateTime.parse(snapshot['startDate'].toDate().toString()),
        endDate = DateTime.parse(snapshot['endDate'].toDate().toString()),
        imageURL = snapshot['imageURL'],
        shop = snapshot['shop'].get();

  //Get shop object
  Future<Shop> get currentShop async {
    DocumentSnapshot doc = await shop;
    Shop currentShop = Shop.fromSnapshot(doc);
    return currentShop;
  }


}
