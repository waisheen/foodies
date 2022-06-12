import 'package:cloud_firestore/cloud_firestore.dart';

class Shop {
  String name;
  int minPrice;
  int maxPrice;
  int closing;
  int opening;
  List<String> openDays;
  String imageURL;

  //Initializer
  Shop(this.name, this.minPrice, this.maxPrice, this.closing, this.opening,
      this.openDays, this.imageURL);

  //Creating Shop object from a snapshot
  Shop.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        minPrice = snapshot['minPrice'],
        maxPrice = snapshot['maxPrice'],
        closing = snapshot['closing'],
        opening = snapshot['opening'],
        openDays = List<String>.from(snapshot['openDays']),
        imageURL = snapshot['imageURL'];

  //Check whether shop is open

}
