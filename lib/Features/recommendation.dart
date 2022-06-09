import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reusablewidgets.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({Key? key}) : super(key: key);

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  Stream<QuerySnapshot> getShopSnapshots(BuildContext context) async* {
    yield* FirebaseFirestore.instance.collection('Shop').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(height: 20),
        buildStream(context, getShopSnapshots(context))
      ],
    );
  }
}
