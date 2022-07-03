import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Reviews/createreview.dart';
import 'package:foodies/ProfilePage/anonymouspage.dart';
import 'package:foodies/Reviews/showreview.dart';
import 'package:foodies/SellerMenu/showitems.dart';
import 'package:foodies/Shop/editshoppage.dart';
import 'package:foodies/Shop/shopdetailsheader.dart';

import '../Models/menu.dart';
import '../Models/review.dart';
import '../Models/shop.dart';
import '../Reviews/showallreviews.dart';
import '../SellerMenu/sellermenupage.dart';
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
  final CollectionReference userInformation = FirebaseFirestore.instance.collection('UserInfo');
  final CollectionReference shops = FirebaseFirestore.instance.collection('Shop');
  final CollectionReference menus = FirebaseFirestore.instance.collection('Menu');
  late Shop? shop = widget.shop;
  late bool isOwner = widget.shop!.sellerID == _auth.currentUser!.uid;

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

  Stream<QuerySnapshot> getMenuSnapshot() async* {
    yield* FirebaseFirestore.instance
        .collection('Menu')
        .where('shop', isEqualTo: widget.shop!.uid)
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: widget.showBackButton ? backButton(context) : null,
      body: shop == null
      ? noShopText(context)
      : CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: ShopDetailsHeader(
                minExtent: 55, 
                maxExtent: MediaQuery.of(context).size.height / 3.5, 
                imageURL: shop!.imageURL,
                text: shop!.name,
                showBackButton: widget.showBackButton
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  emptyBox(10),

                  //display opening hours
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 25),
                    title: const Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text('Opening Hours'),
                    ),
                    subtitle: Text(
                        shop!.operatingHours), //get number from database
                  ),

                  //display Opening Days
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 25),
                    title: const Padding(
                      padding: EdgeInsets.only(bottom: 7),
                      child: Text("Opening Days"),
                    ),
                    subtitle: shop!
                        .getDaysText(context), //get number from database
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
                    subtitle: Text(getCuisine(shop!.options),
                        style: const TextStyle(fontSize: 16)),
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

                  emptyBox(20),

                  //display menu
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 25),
                    title: const Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text("Menu"),
                    ),
                    subtitle: Column(
                      children: [
                        ShowItemsPage(shop: shop),

                        emptyBox(10),

                        //show all items button
                        Container(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SellerMenuPage(
                                        shop: shop,
                                        showBackButton: true)),
                              );
                            },
                            child: const Text('View all items',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  emptyBox(10),

                  //display reviews
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 25),
                    title: const Text("Reviews"),
                    subtitle: Column(
                      children: [
                        //show review
                        ShowReviewPage(shop: shop),

                        emptyBox(10),

                        //view all reviews button
                        Container(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () async {
                              DocumentSnapshot newDoc =
                                  await FirebaseFirestore.instance
                                      .collection('Shop')
                                      .doc(shop!.uid)
                                      .get();
                              Shop newShop = Shop.fromSnapshot(newDoc);
                              if (!mounted) return;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShowAllReviewsPage(
                                            shop: newShop,
                                          )));
                            },
                            child: const Text('View all reviews',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  emptyBox(5),

                  //create review button (only users can leave review)
                  FutureBuilder(
                      future: userInformation
                          .doc(_auth.currentUser?.uid)
                          .get(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        try {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data!.get('role').toString() ==
                                'User') {
                              return leaveReviewButton();
                            } else if (isOwner) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: bigButton("Edit Shop Details",
                                    () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              EditShopPage(
                                                  shop: shop))).then(
                                      (result) =>
                                          setState(() => shop = result));
                                  },),
                                );
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
          ],
        ),
    );
  }

  Widget leaveReviewButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
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
            height: 50,
            child: const Text(
              'No Reviews Yet!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            Review review = Review.fromSnapshot(snapshot.data!.docs[index]);
            return reviewContainer(
              context,
              review,
            );
          },
        );
      },
    );
  }
}
