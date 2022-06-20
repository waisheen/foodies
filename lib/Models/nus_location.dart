import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NUSLocation {
  String uid;
  String name;
  GeoPoint coordinates;

  //Initializer
  NUSLocation(this.uid, this.name, this.coordinates);

  //Creating Location object from a snapshot
  NUSLocation.fromSnapshot(DocumentSnapshot snapshot)
      : uid = snapshot.id,
        name = snapshot['name'],
        coordinates = snapshot['coordinates'];

  //Get location
  LatLng get location {
    return LatLng(coordinates.latitude, coordinates.longitude);
  }
}
