// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodies/Models/shop.dart';

class Menu {
  String uid;
  String details;
  DateTime startDate;
  DateTime endDate;
  String imageURL;
  // ignore: non_constant_identifier_names
  String shop_id;

  final CollectionReference shops =
      FirebaseFirestore.instance.collection("Shop");

  //Initializer

  Menu(this.uid, this.details, this.startDate, this.endDate, this.imageURL,
      this.shop_id);

  //Creating Promotion object from a snapshot
  Menu.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        details = snapshot['details'],
        startDate = DateTime.parse(snapshot['startDate'].toDate().toString()),
        endDate = DateTime.parse(snapshot['endDate'].toDate().toString()),
        imageURL = snapshot['imageURL'],
        shop_id = snapshot['shop_id'];

  // Get shop object
  Future<Shop> get currentShop async {
    DocumentSnapshot doc = await shops.doc(shop_id).get();
    Shop currentShop = Shop.fromSnapshot(doc);
    return currentShop;
  }
}
