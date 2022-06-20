import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Location/showfoodplaces.dart';
import 'package:foodies/Models/nus_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../loading.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with AutomaticKeepAliveClientMixin<LocationPage> {
  final LatLng _initialcameraposition = const LatLng(20.5937, 78.9629);
  late GoogleMapController _controller;
  final Location _location = Location();

  //Get all locations in forms of markers
  Future<Set<Marker>> getLocations() async {
    QuerySnapshot snapshots =
        await FirebaseFirestore.instance.collection('Location').get();
    Iterable<NUSLocation> locations =
        snapshots.docs.map((doc) => NUSLocation.fromSnapshot(doc));
    //Convert to a set of markers
    return locations.map((loc) {
      return Marker(
          markerId: MarkerId(loc.name),
          infoWindow: InfoWindow(title: loc.name),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FoodPlacesPage(
                          location: loc,
                        )));
          },
          position: loc.location);
    }).toSet();
  }

  //Calls the function after map is created
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _location.onLocationChanged.listen((location) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(location.latitude!, location.longitude!),
              zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: FutureBuilder(
            future: getLocations(),
            builder: (context, AsyncSnapshot<Set<Marker>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition:
                      CameraPosition(target: _initialcameraposition),
                  onMapCreated: _onMapCreated,
                  markers: snapshot.data!,
                  myLocationEnabled: true,
                );
              }
              return const Loading();
            })

        /*floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),*/
        );
  }

  @override
  bool get wantKeepAlive => true;
}
