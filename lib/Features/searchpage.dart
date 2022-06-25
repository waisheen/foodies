import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Features/recommendation.dart';
import 'package:foodies/Services/all.dart';

import '../Models/shop.dart';
import '../Shop/shopdetails.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // ignore: unused_field
  final AuthService _auth = AuthService();
  int currentIndex = 0;
  Color color = Colors.blue;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  emptyBox(10),
                  Padding(
                    //choose user type
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        actions: [
                          TextButton(
                            child: Container(
                              height: 50,
                              width: 350,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(children: const [
                                  Icon(Icons.search,
                                      color: Colors.grey, size: 30),
                                  SizedBox(width: 15),
                                  Text(
                                    'Search for a shop!',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  )
                                ]),
                              ),
                            ),
                            onPressed: () async {
                              setState(() => loading = true);
                              QuerySnapshot snapshots = await FirebaseFirestore
                                  .instance
                                  .collection('Shop')
                                  .get();
                              List<String> shopNames = snapshots.docs
                                  .map((doc) => doc['name'] as String)
                                  .toSet()
                                  .toList();
                              setState(() => loading = false);
                              if (!mounted) return;
                              showSearch(
                                  context: context,
                                  delegate: CustomSearchDelegate(
                                      shopNames: shopNames));
                            },
                          ),
                        ]),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      color: Colors.transparent,
                      child: const Text(
                        '  Recommendations',
                        style: TextStyle(fontSize: 30, color: Colors.teal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  emptyBox(
                    30.0,
                  ),
                  const RecommendationPage(),
                ],
              ),
            ),
          );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate({Key? key, required this.shopNames});

  final List<String> shopNames;

  @override
  //Back button
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: (() => close(context, null)),
        icon: const Icon(Icons.arrow_back));
  }

  //Clear search button
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query.isEmpty ? Navigator.pop(context) : query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  //Listview of all suggestions
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = [];
    for (var name in shopNames) {
      if (name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(name);
      }
    }
    return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestions[index]),
            onTap: () => query = suggestions[index],
          );
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Shop')
            .where('name', isEqualTo: query)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }
          return ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: getShops(snapshot.data!.docs, context));
        });
  }

//Make them into shops
  List<Widget> getShops(
      List<QueryDocumentSnapshot> docs, BuildContext context) {
    List<Shop> filtered =
        docs.map((document) => Shop.fromSnapshot(document)).toList();
    return filtered.map((shop) => shopCard(shop, context)).toList();
  }

  //build widget layout for each shop
  Widget shopCard(Shop shop, BuildContext context) {
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
                subtitle: shop.foodPlaceText(context, 14),
              ),
              emptyBox(10),
            ],
          ),
        ),
      ),
    );
  }
}
