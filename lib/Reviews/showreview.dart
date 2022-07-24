//This widget displays all reviews
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/review.dart';
import '../Models/shop.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class ShowReviewPage extends StatefulWidget {
  const ShowReviewPage({Key? key, required this.shop}) : super(key: key);
  final Shop? shop;

  @override
  State<ShowReviewPage> createState() => _ShowReviewPageState();
}

class _ShowReviewPageState extends State<ShowReviewPage> {
  Stream<QuerySnapshot> getReviewSnapshots() async* {
    yield* FirebaseFirestore.instance
        .collection('Review')
        .where('shop', isEqualTo: widget.shop!.uid)
        .limit(1)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: getReviewSnapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }
          if (snapshot.data!.docs.isEmpty) {
            return Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: const SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    'No Reviews Yet!',
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
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
      ),
    );
  }
}
