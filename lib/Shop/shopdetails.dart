import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Reviews/createreview.dart';
import 'package:foodies/ProfilePage/anonymouspage.dart';
import 'package:foodies/Shop/editshoppage.dart';

import '../Models/review.dart';
import '../Models/shop.dart';
import '../Reviews/showreview.dart';
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

  Stream<QuerySnapshot> getReviewSnapshots() async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop!.uid)
        .limit(2)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserReviewSnapshot() async* {
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

            //display opening hours
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Opening Hours'),
              ),
              subtitle:
                  Text(widget.shop!.operatingHours), //get number from database
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

            //display location
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Location"),
              ),
              subtitle: widget.shop!.foodPlaceText(context, 16),
            ),

            //display cuisine
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Cuisine"),
              ),
              subtitle: Text(widget.shop!.cuisine, style: const TextStyle(fontSize: 16)),
            ),

            //display dietary req
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Food is:"),
              ),
              subtitle: Row(
                children: [
                  dietBox(widget.shop!.halal, "Halal"),
                  dietBox(widget.shop!.vegetarian, "Vegetarian")
                ],
              ),
            ),

            //display reviews (2 only)
            SizedBox(
              width: 400,
              child: buildReviewStream(
                context,
                getReviewSnapshots(),
                widget.shop!.uid,
              ),
            ),

            emptyBox(10),

            //view all reviews button
            Padding(
              padding: const EdgeInsets.only(left: 32.5),
              child: Container(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () async {
                    DocumentSnapshot newDoc = await FirebaseFirestore.instance
                        .collection('Shop')
                        .doc(widget.shop!.uid)
                        .get();
                    Shop newShop = Shop.fromSnapshot(newDoc);
                    if (!mounted) return;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowReviewsPage(
                                  shop: newShop,
                                )));
                  },
                  child: const Text('View all reviews',
                      style: TextStyle(color: Colors.blue, fontSize: 13)),
                ),
              ),
            ),

            emptyBox(15),

            //create review button (only users can leave review)
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
                      await getUserReviewSnapshot().first;
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

//This widget displays all reviews
  Widget buildReviewStream(
      BuildContext context, Stream<QuerySnapshot> stream, String shopID) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Loading();
        }
        if (snapshot.data!.docs.isEmpty) {
          return Container(
              alignment: Alignment.center,
              width: 400,
              height: 200,
              child: const Text(
                'No Reviews Yet!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ));
        }
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              Review review =
                  Review.fromSnapshot(snapshot.data!.docs[index]);
              return reviewContainer(
                context,
                review,
              );
            }
        );
      },
  );
  }
}
