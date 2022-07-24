import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../loading.dart';

class ShopRecommendationPage extends StatefulWidget {
  const ShopRecommendationPage({Key? key, required this.function})
      : super(key: key);

  final List<Widget> Function(List<QueryDocumentSnapshot>, BuildContext context)
      function;

  @override
  State<ShopRecommendationPage> createState() => _ShopRecommendationPageState();
}

class _ShopRecommendationPageState extends State<ShopRecommendationPage> {
  //This collect all shops available, can be further filtered
  Stream<QuerySnapshot> getShopSnapshots() async* {
    yield* FirebaseFirestore.instance.collection('Shop').limit(8).snapshots();
  }

  late final _shopSnapshots = getShopSnapshots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: _shopSnapshots,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Loading();
            }
            return ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                scrollDirection: Axis.horizontal,
                children: widget.function(snapshot.data!.docs, context));
          },
        ));
  }
}
