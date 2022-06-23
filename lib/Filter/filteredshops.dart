import 'package:flutter/material.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Features/shopdetails.dart';
import '../Models/shop.dart';

class FilteredShopsPage extends StatefulWidget {
  const FilteredShopsPage({Key? key, required this.shopList}) : super(key: key);
  final List<Shop> shopList;

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
          children:
              widget.shopList.map((shop) => shopCard(context, shop)).toList(),
        ));
  }
}

//build widget layout for each promo
Widget shopCard(BuildContext context, Shop shop) {
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
              subtitle: Text(shop.operatingHours),
            ),
            emptyBox(10),
          ],
        ),
      ),
    ),
  );
}
