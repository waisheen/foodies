import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/menu.dart';
import '../Models/shop.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class ShowItemsPage extends StatefulWidget {
  const ShowItemsPage({Key? key, required this.shop}) : super(key: key);
  final Shop? shop;

  @override
  State<ShowItemsPage> createState() => _ShowItemsPageState();
}

class _ShowItemsPageState extends State<ShowItemsPage> {
  final CollectionReference menus =
      FirebaseFirestore.instance.collection('Menu');
  late Shop? shop = widget.shop;

  Stream<QuerySnapshot> getMenuSnapshot() async* {
    yield* FirebaseFirestore.instance
        .collection('Menu')
        .where('shop', isEqualTo: widget.shop!.uid)
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: getMenuSnapshot(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }
          if (snapshot.data!.docs.isEmpty) {
            return Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'No Menu Items Yet!',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            );
          }
          return CustomScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(menuList(
                    snapshot.data!.docs, context, false, widget.shop!.uid)),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> menuList(List<QueryDocumentSnapshot<Object?>> docsList,
      BuildContext context, bool canEdit, String shopID) {
    List filtered = docsList
        .map((document) => Menu.fromSnapshot(document))
        .where((menu) => menu.shop_id == shopID)
        .toList();

    List<Widget> widgetList =
        filtered.map((menu) => menuWidget(menu, context, canEdit)).toList();
    return widgetList;
  }

  Widget menuWidget(Menu item, BuildContext context, bool canEdit) {
    return SizedBox(
      width: 150,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: <Widget>[
            Image(
              image: NetworkImage(item.imageURL),
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                //placeholder picture in the case image cannot be displayed
                return const Image(
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  image: AssetImage('assets/images/logo5.png'),
                );
              },
            ),
            emptyBox(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child:
                        Text(item.name, style: const TextStyle(fontSize: 10)),
                  ),
                  const SizedBox(width: 5),
                  Text("\$${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
