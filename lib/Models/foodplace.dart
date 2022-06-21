import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPlace {
  String uid;
  String name;
  String imageURL;
  String location;

  //Initializer
  FoodPlace(this.uid, this.name, this.imageURL, this.location);

  //Creating Shop object from a snapshot
  FoodPlace.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        name = snapshot['name'],
        location = snapshot['location'],
        imageURL = snapshot['imageURL'];

  //Creating FoodPlace from JSON
  FoodPlace.fromJson(Map<String, Object?> json)
      : uid = json['uid'] as String,
        location = json['location'] as String,
        name = json['name'] as String,
        imageURL = json['imageURL'] as String;
}
