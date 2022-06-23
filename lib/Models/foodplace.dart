import 'package:cloud_firestore/cloud_firestore.dart';

import '../reusablewidgets.dart';

class FoodPlace {
  String uid;
  String name;
  String imageURL;
  String location;
  GeoPoint coordinates;

  //Initializer
  FoodPlace(
      this.uid, this.name, this.imageURL, this.location, this.coordinates);

  //Creating Shop object from a snapshot
  FoodPlace.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        name = snapshot['name'],
        location = snapshot['location'],
        coordinates = snapshot['coordinates'],
        imageURL = snapshot['imageURL'];

  //Creating FoodPlace from JSON
  FoodPlace.fromJson(Map<String, Object?> json)
      : uid = json['uid'] as String,
        location = json['location'] as String,
        name = json['name'] as String,
        coordinates = json['coordinates'] as GeoPoint,
        imageURL = json['imageURL'] as String;

  //Calculate Distance
  int distanceFrom(currLat, currLong) {
    return distance(
        currLat, coordinates.latitude, currLong, coordinates.longitude);
  }
}
