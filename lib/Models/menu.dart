import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodies/Models/shop.dart';

class Menu {
  String uid;
  String name;
  double price;
  String imageURL;
  // ignore: non_constant_identifier_names
  String shop_id;

  final CollectionReference shops = FirebaseFirestore.instance.collection("Shop");

  //Initializer

  Menu(this.uid, this.name, this.price, this.imageURL, this.shop_id);

  //Creating Promotion object from a snapshot
  Menu.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        name = snapshot['name'],
        price = snapshot['price'].toDouble(),
        imageURL = snapshot['imageURL'],
        shop_id = snapshot['shop'];

  // Get shop object
  Future<Shop> get currentShop async {
    DocumentSnapshot doc = await shops.doc(shop_id).get();
    Shop currentShop = Shop.fromSnapshot(doc);
    return currentShop;
  }
}