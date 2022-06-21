import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Features/createreview.dart';
import 'package:foodies/ProfilePage/anonymouspage.dart';
import 'package:foodies/Shop/editshoppage.dart';

import '../Models/review.dart';
import '../Models/shop.dart';
import '../Services/all.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({Key? key, required this.shop, required this.showBackButton}) : super(key: key);
  final Shop? shop;
  final bool showBackButton;

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final AuthService _auth = AuthService();
  final CollectionReference userInformation = FirebaseFirestore.instance.collection('UserInfo');

  Stream<QuerySnapshot> getReviewSnapshots(BuildContext context) async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserReviewSnapshot(BuildContext context) async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop!.uid)
        .where('user', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: widget.showBackButton ? backButton(context) : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                //backdrop image
                Image(
                  image: NetworkImage(widget.shop!.imageURL),
                  height: MediaQuery.of(context).size.height / 4,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                          "https://m.media-amazon.com/images/M/MV5BNGFhZWFhMjAtOTU1Yy00NTk1LThmZDMtYzZiMGM4NzkyZTlhL2ltYWdlL2ltYWdlXkEyXkFqcGdeQXVyNDk2NDYyMTk@._V1_.jpg"),
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
                subtitle: Text(widget.shop!.name, style: const TextStyle(fontSize: 16)) //get shopv name from database
                ),

            //display Opening Days
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Opening Days"),
              ),
              subtitle:
                  widget.shop!.getDaysText(context), //get number from database
            ),

            //display opening hours
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Opening Hours"),
              ),
              subtitle: Text("${widget.shop!.opening.toString().padLeft(4, "0")}  -  ${widget.shop!.closing.toString().padLeft(4, "0")} Hours",
                style: const TextStyle(fontSize: 16)),
              //get number from database
            ),

            //display minmax prices
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Prices"),
              ),
              subtitle: Text(
                  '\$${widget.shop!.minPrice} to \$${widget.shop!.maxPrice}', //get number from database
                  style: const TextStyle(fontSize: 16)), 
            ),

            //display foodplace
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Location"),
              ),
              subtitle: widget.shop!.foodPlaceText(context),
            ),

            //display reviews
            SizedBox(
              width: 400,
              height: 200,
              child: buildReviewStream(
                context,
                getReviewSnapshots(context),
                widget.shop!.uid,
              ),
            ),

            emptyBox(15),

            //create review button
            FutureBuilder(
              future: userInformation.doc(_auth.currentUser?.uid).get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                try {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data!.get('role').toString() == 'User') {
                      return leaveReviewButton();
                    } else if (AuthService().currentUser!.uid == widget.shop!.sellerID) {
                    return editShopButton();
                    }
                  }
                  return emptyBox(1);
                } catch (e) {
                  return emptyBox(1);
                }
              }
            ),

            emptyBox(20)
          ],
        ),
      ),
    );
  }

  Widget leaveReviewButton() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Container(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: _auth.currentUser!.isAnonymous
              ? () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AnonymousPage()));
                }
              : () async {
                  QuerySnapshot futureUserReview =
                      await getUserReviewSnapshot(context).first;
                  Review? review;
                  try {
                    review = Review.fromSnapshot(
                        futureUserReview.docs.first);
                  } catch (e) {
                    review = null;
                  }
                  DocumentSnapshot newDoc = await FirebaseFirestore
                      .instance
                      .collection('Shop')
                      .doc(widget.shop!.uid)
                      .get();
                  Shop newShop = Shop.fromSnapshot(newDoc);
                  if (!mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateReviewPage(
                                review: review,
                                shop: newShop,
                              )));
                },
          child: const Text('Leave a Review',
              style: TextStyle(color: Colors.blue, fontSize: 13)),
        ),
      ),
    );
  }

  Widget editShopButton() {
    return Container(
      height: 50.0,
      width: 300.0,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.red),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditShopPage(shop: widget.shop)));
        },
        child: const Text(
          "Edit Shop Details",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
