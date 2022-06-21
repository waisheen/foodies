//This widget displays all reviews
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/review.dart';
import '../Models/shop.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class ShowReviewsPage extends StatefulWidget {
  const ShowReviewsPage({Key? key, required this.shop}) : super(key: key);
  final Shop shop;

  @override
  State<ShowReviewsPage> createState() => _ShowReviewsPageState();
}

class _ShowReviewsPageState extends State<ShowReviewsPage> {
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
        extendBodyBehindAppBar: true,
        appBar: backButton(context),
        body: Padding(
          padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
          child: buildAllReviewStream(
              context, getReviewSnapshots(), widget.shop.uid),
        ));
  }
}

//Show all reviews
Widget buildAllReviewStream(
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
                  return const Text('No Reviews Yet!');
                }
                return ListView.builder(
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
