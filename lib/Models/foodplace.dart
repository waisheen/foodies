import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPlace {
  String name;
  String imageURL;

  //Initializer
  FoodPlace(this.name, this.imageURL);

  //Creating Shop object from a snapshot
  FoodPlace.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        imageURL = snapshot['imageURL'];

  //Creating FoodPlace from JSON
  FoodPlace.fromJson(Map<String, Object?> json)
      : name = json['name'] as String,
        imageURL = json['imageURL'] as String;
}
