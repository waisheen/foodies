//This widget displays all reviews
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/theme.dart';

import '../Models/review.dart';
import '../Models/shop.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class ShowAllReviewsPage extends StatefulWidget {
  const ShowAllReviewsPage({Key? key, required this.shop}) : super(key: key);
  final Shop shop;

  @override
  State<ShowAllReviewsPage> createState() => _ShowAllReviewsPageState();
}

class _ShowAllReviewsPageState extends State<ShowAllReviewsPage> {
  Stream<QuerySnapshot> getReviewSnapshots() async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: backButton(context, "All Reviews", themeColour),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: buildAllReviewStream(
            context, getReviewSnapshots(), widget.shop.uid),
      ),
    );
  }
}

//Show all reviews
Widget buildAllReviewStream(
    BuildContext context, Stream<QuerySnapshot> stream, String shopID) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      // Text(
      //   'Reviews',
      //   style: TextStyle(
      //       color: themeColour, fontSize: 35.0, fontWeight: FontWeight.bold),
      //   textAlign: TextAlign.left,
      // ),
      Flexible(
        fit: FlexFit.loose,
        child: StreamBuilder(
            stream: stream,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Loading();
              }
              if (snapshot.data!.docs.isEmpty) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: Text(
                      'No Reviews Yet!',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
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
            }),
      ),
    ],
  );
}
