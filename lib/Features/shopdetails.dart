import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Reviews/createreview.dart';
import 'package:foodies/ProfilePage/anonymouspage.dart';

import '../Models/review.dart';
import '../Models/shop.dart';
import '../Reviews/showreview.dart';
import '../Services/all.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({Key? key, required this.shop}) : super(key: key);
  final Shop shop;

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final AuthService _auth = AuthService();

  Stream<QuerySnapshot> getReviewSnapshots() async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop.uid)
        .limit(2)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserReviewSnapshot() async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop.uid)
        .where('user', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: backButton(context),
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

            //display opening hours
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Opening Hours'),
              ),
              subtitle:
                  Text(widget.shop.operatingHours), //get number from database
            ),

            //display Opening Days
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Opening Days"),
              ),
              subtitle:
                  widget.shop.getDaysText(context), //get number from database
            ),

            //display minmax prices
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Prices"),
              ),
              subtitle: Text(
                  '\$${widget.shop.minPrice} - \$${widget.shop.maxPrice}'), //get number from database
            ),

            //display location
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Location"),
              ),
              subtitle: widget.shop.foodPlaceText(context),
            ),

            //display reviews (2 only)
            SizedBox(
              width: 400,
              height: 200,
              child: buildReviewStream(
                context,
                getReviewSnapshots(),
                widget.shop.uid,
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
                        .doc(widget.shop.uid)
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

            emptyBox(10),

            //create review button
            Padding(
              padding: const EdgeInsets.only(left: 32.5),
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
                              .doc(widget.shop.uid)
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
            ),

            emptyBox(20),
          ],
        ),
      ),
    );
  }
}

//This widget displays all reviews
Widget buildReviewStream(
    BuildContext context, Stream<QuerySnapshot> stream, String shopID) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Flexible(
          fit: FlexFit.loose,
          child: StreamBuilder(
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
                    });
              })),
    ],
  );
}
