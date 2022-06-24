import 'package:flutter/material.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Models/shop.dart';
import '../Shop/shopdetails.dart';

class FilteredShopsPage extends StatefulWidget {
  const FilteredShopsPage(
      {Key? key, required this.shopList, required this.distances})
      : super(key: key);
  final List<Shop> shopList;
  final List<int> distances;

  @override
  State<FilteredShopsPage> createState() => _FilteredShopsPageState();
}

class _FilteredShopsPageState extends State<FilteredShopsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: backButton(context),
        body: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          children: getWidgets(context, widget.shopList, widget.distances),
        ));
  }
}

//building widget list from 2 lists
List<Widget> getWidgets(
    BuildContext context, List<Shop> shopList, List<int> distances) {
  List<Widget> widgetList = List<Widget>.empty(growable: true);
  for (int i = 0; i < shopList.length; i++) {
    widgetList.add(shopCard(context, shopList[i], distances[i]));
  }
  return widgetList;
}

//build widget layout for each promo
Widget shopCard(BuildContext context, Shop shop, int distance) {
  return Card(
    clipBehavior: Clip.hardEdge,
    elevation: 20,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ShopDetailsPage(shop: shop, showBackButton: true))),
      splashColor: Colors.teal.shade600.withOpacity(0.5),
      child: Ink(
        child: Column(
          children: <Widget>[
            Image(
              image: NetworkImage(shop.imageURL),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            emptyBox(5),
            ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(shop.name),
                ),
                subtitle: Text('$distance m')),
            emptyBox(10),
          ],
        ),
      ),
    ),
  );
}
