import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/SearchPage/shoprecommendation.dart';
import 'package:location/location.dart';

import '../Models/foodplace.dart';
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

                  //Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        actions: [
                          TextButton(
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width - 40,
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
                  emptyBox(15),

                  //Recommendations header
                  Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    child: Text(
                      '  Recommendations',
                      style: TextStyle(
                          fontSize: 30,
                          color: themeColour,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  emptyBox(
                    15.0,
                  ),

                  //recommendations based on highest ratings
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    title: Row(
                      children: const [
                        Icon(
                          Icons.star_outline,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Highest Ratings',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    subtitle:
                        const ShopRecommendationPage(function: ratingList),
                  ),

                  emptyBox(20),

                  //recommendations by number of reviews
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    title: Row(
                      children: const [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Most Popular',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    subtitle:
                        const ShopRecommendationPage(function: numberList),
                  ),

                  emptyBox(20),

                  //recommendations by cheaper options
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    title: Row(
                      children: const [
                        Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Cheaper Options',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    subtitle: const ShopRecommendationPage(function: cheapList),
                  ),

                  emptyBox(20),

                  //recommendations by drinks/desserts
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    title: Row(
                      children: const [
                        Icon(
                          Icons.local_drink,
                          color: Colors.brown,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Drinks and Desserts',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    subtitle:
                        const ShopRecommendationPage(function: drinksList),
                  ),
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

  //build widget layout for each shop for search function
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
    );
  }
}

//Builds a card with a title, image and a onTap fuction for recommendations
Widget buildCard(BuildContext context, Shop shop, void Function() onTapped) {
  return SizedBox(
    width: 225,
    height: 200,
    child: Card(
      clipBehavior: Clip.hardEdge,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTapped,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image(
              image: NetworkImage(shop.imageURL),
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                //placeholder picture in the case image cannot be displayed
                return const Image(
                    image: AssetImage('assets/images/logo5.png'),
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.contain);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Text(
                shop.name,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 3),
              child: shop.foodPlaceText(context, 11),
            ),
            emptyBox(7.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  shop.showRatings(context),
                  const SizedBox(width: 15),
                  Text(
                    '${shop.averageRating.toStringAsFixed(1)} / 5.0',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//This sorts shops by ratings, with minimum number of reviews
List<Widget> ratingList(
    List<QueryDocumentSnapshot> docsList, BuildContext context) {
  List<Shop> filtered = docsList
      .map((document) => Shop.fromSnapshot(document))
      .where((shop) => shop.totalReview >= 3)
      .toList();

  //sort shops acc to ratings
  filtered.sort((shop1, shop2) {
    double rating1 = shop1.averageRating;
    double rating2 = shop2.averageRating;
    if (rating1 - rating2 > 0) {
      return -1;
    }
    return 1;
  });
  List<Widget> widgetList = filtered
      .map((shop) => buildCard(
            context,
            shop,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}

//This sorts shops by number of reviews
List<Widget> numberList(
    List<QueryDocumentSnapshot> docsList, BuildContext context) {
  List<Shop> filtered =
      docsList.map((document) => Shop.fromSnapshot(document)).toList();

  //sort shops acc to number of reviews
  filtered.sort((shop1, shop2) {
    double rating1 = shop1.totalReview;
    double rating2 = shop2.totalReview;
    if (rating1 - rating2 > 0) {
      return -1;
    }
    return 1;
  });
  List<Widget> widgetList = filtered
      .map((shop) => buildCard(
            context,
            shop,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}

//This returns a recommendation page, but it's a future
Widget futureRecommendation(
    Future<
            List<Widget> Function(
                List<QueryDocumentSnapshot> docsList, BuildContext context)>
        function) {
  return FutureBuilder(
    future: function,
    builder: (BuildContext context,
        AsyncSnapshot<
                List<Widget> Function(
                    List<QueryDocumentSnapshot> docsList, BuildContext context)>
            snapshot) {
      if (!snapshot.hasData) {
        return const Loading();
      }
      return ShopRecommendationPage(function: snapshot.data!);
    },
  );
}

//This sorts shops by distance, then ratings
Future<List<Widget>> distanceListFuture(
    List<QueryDocumentSnapshot> docsList, BuildContext context) async {
  List<Shop> filtered =
      docsList.map((document) => Shop.fromSnapshot(document)).toList();

  //Get all foodplaces
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('FoodPlace').get();
  List<FoodPlace> foodplaces =
      snapshot.docs.map((snap) => FoodPlace.fromSnapshot(snap)).toList();

  //sort by location
  LocationData location = await Location().getLocation();
  List<GeoPoint> geoPoints =
      filtered.map((shop) => getGeoPoints(foodplaces, shop)!).toList();
  List<int> distances = geoPoints
      .map((geoPoint) => distance(geoPoint.latitude, geoPoint.longitude,
          location.latitude, location.longitude))
      .toList();

  //Some random bubble sorting
  for (int i = 0; i < filtered.length - 1; i++) {
    for (int j = i; j < filtered.length; j++) {
      if (distances[i] > distances[j]) {
        int temp = distances[j];
        distances[j] = distances[i];
        distances[i] = temp;
        Shop tempShop = filtered[j];
        filtered[j] = filtered[i];
        filtered[i] = tempShop;
      }
    }
  }

  //sort shops acc to number of reviews
  filtered.sort((shop1, shop2) {
    double rating1 = shop1.totalReview;
    double rating2 = shop2.totalReview;
    if (rating1 - rating2 > 0) {
      return -1;
    }
    return 1;
  });
  List<Widget> widgetList = filtered
      .map((shop) => buildCard(
            context,
            shop,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}

//Functions
GeoPoint? getGeoPoints(List<FoodPlace> foodplaces, Shop shop) {
  for (var foodplace in foodplaces) {
    if (foodplace.uid == shop.foodPlace) {
      return foodplace.coordinates;
    }
  }
  return null;
}

//This sorts shops by desserts/beverages then ratings
List<Widget> drinksList(
    List<QueryDocumentSnapshot> docsList, BuildContext context) {
  List<Shop> filtered =
      docsList.map((document) => Shop.fromSnapshot(document)).toList();

  //take out those that has drinks/desserts
  filtered = filtered
      .where((shop) =>
          shop.options.contains('Drinks') || shop.options.contains('Dessert'))
      .toList();

  //sort shops acc to ratings
  filtered.sort((shop1, shop2) {
    double rating1 = shop1.averageRating;
    double rating2 = shop2.averageRating;
    if (rating1 - rating2 > 0) {
      return -1;
    }
    return 1;
  });
  List<Widget> widgetList = filtered
      .map((shop) => buildCard(
            context,
            shop,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}

//This sorts shops by shops that offer food below $5 then ratings
List<Widget> cheapList(
    List<QueryDocumentSnapshot> docsList, BuildContext context) {
  List<Shop> filtered =
      docsList.map((document) => Shop.fromSnapshot(document)).toList();

  //take out those that has drinks/desserts
  filtered = filtered
      .where((shop) => shop.minPrice <= 5 && shop.minPrice >= 2)
      .toList();

  //sort shops acc to ratings
  filtered.sort((shop1, shop2) {
    double rating1 = shop1.averageRating;
    double rating2 = shop2.averageRating;
    if (rating1 - rating2 > 0) {
      return -1;
    }
    return 1;
  });
  List<Widget> widgetList = filtered
      .map((shop) => buildCard(
            context,
            shop,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ShopDetailsPage(shop: shop, showBackButton: true))),
          ))
      .toList();
  return widgetList;
}
