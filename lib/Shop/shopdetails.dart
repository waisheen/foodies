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
  const ShopDetailsPage(
      {Key? key, required this.shop, required this.showBackButton})
      : super(key: key);
  final Shop? shop;
  final bool showBackButton;

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final AuthService _auth = AuthService();
  final CollectionReference userInformation =
      FirebaseFirestore.instance.collection('UserInfo');
  final CollectionReference shops =
      FirebaseFirestore.instance.collection('Shop');
  late Shop? shop = widget.shop;

  Stream<QuerySnapshot> getReviewSnapshots() async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop!.uid)
        .limit(1)
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
      body: shop == null ? 
      noShopText(context) : 
      SingleChildScrollView(
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
                  image: NetworkImage(shop!.imageURL),
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                  //placeholder picture in the case image cannot be displayed
                  return Image(
                    image: const AssetImage('assets/images/logo5.png'),
                    height: MediaQuery.of(context).size.height / 3.5,
                    width: double.infinity,
                    fit: BoxFit.contain
                  );
                  },
                ),
              ],
            ),

            emptyBox(20),

            //Shop name
            ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Shop Name"),
                ),
                subtitle: Text(shop!.name,
                    style: const TextStyle(
                        fontSize: 16)) //get shopv name from database
                ),

            //display opening hours
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Opening Hours'),
              ),
              subtitle:
                  Text(shop!.operatingHours), //get number from database
            ),

            //display Opening Days
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text("Opening Days"),
              ),
              subtitle:
                  shop!.getDaysText(context), //get number from database
            ),

            //display minmax prices
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Prices"),
              ),
              subtitle: Text(
                  '\$${shop!.minPrice} to \$${shop!.maxPrice}', //get number from database
                  style: const TextStyle(fontSize: 16)),
            ),

            //display location
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Location"),
              ),
              subtitle: shop!.foodPlaceText(context, 16),
            ),

            //display cuisine
            ListTile(
              contentPadding: const EdgeInsets.only(left: 25),
              title: const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Cuisine"),
              ),
              subtitle: Text(getCuisine(shop!.options), style: const TextStyle(fontSize: 16)),
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
                  dietBox(isHalal(shop!.options), "Halal"),
                  dietBox(isVegetarian(shop!.options), "Vegetarian")
                ],
              ),
            ),

            //display reviews (2 only)
            SizedBox(
              width: 400,
              child: buildReviewStream(
                context,
                getReviewSnapshots(),
                shop!.uid,
              ),
            ),

            emptyBox(10),

            //view all reviews button
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () async {
                    DocumentSnapshot newDoc = await FirebaseFirestore.instance
                        .collection('Shop')
                        .doc(shop!.uid)
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
                      } else if (AuthService().currentUser!.uid ==
                          shop!.sellerID) {
                        return bigButton("Edit Shop Details", () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => EditShopPage(shop: shop)))
                                  .then((result) => setState(() => shop = result));
                        });
                      }
                    }
                    return emptyBox(1);
                  } catch (e) {
                    return emptyBox(1);
                  }
                }),

            emptyBox(20)
          ],
        ),
      ),
    );
  }

  Widget leaveReviewButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
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
                    review = Review.fromSnapshot(futureUserReview.docs.first);
                  } catch (e) {
                    review = null;
                  }
                  DocumentSnapshot newDoc = await FirebaseFirestore.instance
                      .collection('Shop')
                      .doc(shop!.uid)
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
            width: 300,
            height: 150,
            child: const Text(
              'No Reviews Yet!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              Review review = Review.fromSnapshot(snapshot.data!.docs[index]);
              return reviewContainer(
                context,
                review,
              );
            });
      },
    );
  }
}
