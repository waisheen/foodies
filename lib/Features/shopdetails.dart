import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/shop.dart';
import '../reusablewidgets.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({Key? key, required this.shop}) : super(key: key);
  final Shop shop;

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final CollectionReference shopInformation =
      FirebaseFirestore.instance.collection('Shop');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                //backdrop image
                Image(
                  image: const NetworkImage(
                      "https://static.vecteezy.com/system/resources/previews/005/489/284/non_2x/beautiful-purple-color-gradient-background-free-vector.jpg"),
                  height: MediaQuery.of(context).size.height / 5,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),

                //profile picture
                const Positioned(
                  bottom: -70,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(
                          "https://pbs.twimg.com/media/EdxsmDKWAAI2h5v.jpg"),
                    ),
                  ),
                ),
              ],
            ),

            emptyBox(70),

            //Shop name
            ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Shop Name"),
                ),
                subtitle: Text(widget.shop.name) //get shopv name from database
                ),

            //display Opening Days
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Opening Days"),
              ),
              subtitle: widget.shop.getDaysText(), //get number from database
            ),

            //display minmax prices
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Prices"),
              ),
              subtitle: Text(
                  '\$${widget.shop.minPrice} to \$${widget.shop.maxPrice}'), //get number from database
            ),

            //display foodplace
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Location"),
              ),
              subtitle: widget.shop.foodPlaceText(context),
            ),

            emptyBox(20),

            backButton(context),

            //edit profile button
            bigButton("Edit Profile", () {})
          ],
        ),
      ),
    );
  }
}
