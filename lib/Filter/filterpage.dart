import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Filter/filteredshops.dart';
import 'package:foodies/Models/nus_location.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:location/location.dart';

import '../Models/foodplace.dart';
import '../Models/shop.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  bool loading = false;
  //initial slider values and locations
  RangeValues _currentRange = const RangeValues(0, 10);
  String selectedLocation = 'All';

  //List of all food options
  final List<String> _foodOptions = Shop.allOptions;
  List<String> _selectedOptions = [];

  //get list of locations
  Stream<QuerySnapshot> getLocations() async* {
    yield* FirebaseFirestore.instance.collection('Location').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  emptyBox(80),

                  //For slider
                  ListTile(
                    title: const Text('Price Range'),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          size: 35,
                          color: themeColour,
                        ),
                        Expanded(
                            child: RangeSlider(
                                inactiveColor: Colors.grey,
                                activeColor: themeColour,
                                values: _currentRange,
                                min: 0,
                                max: 25,
                                divisions: 25,
                                labels: RangeLabels(
                                    _currentRange.start.round().toString(),
                                    _currentRange.end.round().toString()),
                                onChanged: (RangeValues range) {
                                  setState(() => _currentRange = range);
                                }))
                      ],
                    ),
                  ),

                  emptyBox(40),

                  //for filtering locations
                  ListTile(
                      title: const Text('Locations'),
                      subtitle: StreamBuilder(
                        stream: getLocations(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return const Loading();
                          }
                          List<NUSLocation> locations = snapshot.data!.docs
                              .map((doc) => NUSLocation.fromSnapshot(doc))
                              .toList();
                          List<String> options =
                              locations.map((loc) => loc.name).toList();
                          options.add('All');

                          //Return formfield
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 20),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  prefixIcon: const Icon(
                                    Icons.place,
                                    color: Colors.red,
                                  )),
                              hint: Text(selectedLocation),
                              isExpanded: true,
                              items: options.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(
                                    () => selectedLocation = val.toString());
                              },
                            ),
                          );
                        },
                      )),

                  emptyBox(40),

                  //Filtering options
                  ListTile(
                    title: const Text('Food Options'),
                    subtitle: Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey)),
                        child: SmartSelect<String>.multiple(
                            title: '',
                            placeholder: 'Choose options',
                            selectedValue: _selectedOptions,
                            modalValidation: (value) {
                              return value.isEmpty ? 'Select at least one' : '';
                            },
                            modalHeaderStyle: S2ModalHeaderStyle(
                                backgroundColor: themeColour),
                            onChange: (selected) {
                              setState(
                                  () => _selectedOptions = selected!.value!);
                            },
                            choiceItems: _foodOptions
                                .map((string) => S2Choice<String>(
                                    title: string, value: string))
                                .toList(),
                            choiceType: S2ChoiceType.switches,
                            choiceActiveStyle: S2ChoiceStyle(
                              color: themeColour,
                            ),
                            modalFilter: true,
                            modalConfirm: true,
                            modalType: S2ModalType.fullPage,
                            modalFooterBuilder: (context, state) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  bigButton(
                                    'Select All',
                                    () {
                                      state.selection!
                                          .toggle(state.choices!.items!);
                                    },
                                  ),
                                  /*ActionButton(
                          label: const Text('Low End'),
                          onTap: () {
                            state.selection.choice = state.choices.items
                                .where((item) =>
                                    item.meta['category'] == 'Budget Phone')
                                .toList();
                          },
                        ),
                        ActionButton(
                          label: const Text('Mid End'),
                          onTap: () {
                            state.selection.choice = state.choices.items
                                .where((item) =>
                                    item.meta['category'] == 'Mid End Phone')
                                .toList();
                          },
                        ),
                        ActionButton(
                          label: const Text('High End'),
                          onTap: () {
                            state.selection.choice = state.choices.items
                                .where((item) =>
                                    item.meta['category'] == 'Flagship Phone')
                                .toList();
                  }
                        ),*/
                                ],
                              );
                            },
                            tileBuilder: (context, state) {
                              return S2Tile.fromState(
                                state,
                                //hideValue: true,
                                trailing: const Icon(Icons.add_circle_outline),
                                leading: const Icon(
                                  Icons.fastfood,
                                  color: Colors.amber,
                                ),
                                body: S2TileChips(
                                  chipColor: Theme.of(context).primaryColor,
                                  chipLength: state.choices!.length,
                                  chipLabelBuilder: (context, i) {
                                    return Text(
                                        state.selected!.choice![i].title!);
                                  },
                                  chipOnDelete: (i) {
                                    setState(() {
                                      _selectedOptions.remove(
                                          state.selected!.choice![i].value);
                                    });
                                  },
                                ),
                              );
                            }),
                      ),
                    ),
                  ),

                  emptyBox(40),
                  bigButton('Filter', () async {
                    setState(() => loading = true);
                    //Get all shops
                    QuerySnapshot shopSnapshots = await FirebaseFirestore
                        .instance
                        .collection('Shop')
                        .get();
                    List<Shop> shops = shopSnapshots.docs
                        .map((docs) => Shop.fromSnapshot(docs))
                        .toList();

                    //Get foodplaces
                    QuerySnapshot foodplaceSnapshots;
                    if (selectedLocation == 'All') {
                      foodplaceSnapshots = await FirebaseFirestore.instance
                          .collection('FoodPlace')
                          .get();
                    } else {
                      QuerySnapshot locationSnapshots = await FirebaseFirestore
                          .instance
                          .collection('Location')
                          .where('name', isEqualTo: selectedLocation)
                          .get();
                      NUSLocation loc = NUSLocation.fromSnapshot(
                          locationSnapshots.docs.first);
                      foodplaceSnapshots = await FirebaseFirestore.instance
                          .collection('FoodPlace')
                          .where('location', isEqualTo: loc.uid)
                          .get();
                    }

                    //Filter shops based on foodplaces
                    List<String> foodPlaces =
                        foodplaceSnapshots.docs.map((docs) => docs.id).toList();
                    List<FoodPlace> places = foodplaceSnapshots.docs
                        .map((docs) => FoodPlace.fromSnapshot(docs))
                        .toList();
                    shops = shops
                        .where((shop) => (foodPlaces.contains(shop.foodPlace)))
                        .toList();

                    //Filter shops based on price range
                    shops = shops.where((shop) {
                      return (shop.minPrice >= _currentRange.start &&
                              shop.minPrice <= _currentRange.end) ||
                          (shop.maxPrice >= _currentRange.start &&
                              shop.maxPrice <= _currentRange.end);
                    }).toList();

                    //Filter by options
                    List<String> options = _selectedOptions.isEmpty
                        ? Shop.allOptions
                        : _selectedOptions;
                    shops = shops
                        .where((shop) =>
                            shop.options.any((opt) => options.contains(opt)))
                        .toList();

                    //Get distances and combine into the list
                    List<GeoPoint> geoPoints = shops
                        .map((shop) => getGeoPoint(places, shop)!)
                        .toList();
                    LocationData location = await Location().getLocation();
                    List<int> distances = geoPoints
                        .map((geoPoint) => distance(
                            geoPoint.latitude,
                            geoPoint.longitude,
                            location.latitude,
                            location.longitude))
                        .toList();

                    //Some random bubble sorting
                    for (int i = 0; i < shops.length - 1; i++) {
                      for (int j = i; j < shops.length; j++) {
                        if (distances[i] > distances[j]) {
                          int temp = distances[j];
                          distances[j] = distances[i];
                          distances[i] = temp;
                          Shop tempShop = shops[j];
                          shops[j] = shops[i];
                          shops[i] = tempShop;
                        }
                      }
                    }

                    //Set state to not loading

                    if (!mounted) return;
                    setState(() => loading = false);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FilteredShopsPage(
                                  shopList: shops,
                                  distances: distances,
                                )));
                  })
                ],
              ),
            ),
          );
  }
}

//Functions
GeoPoint? getGeoPoint(List<FoodPlace> foodplaces, Shop shop) {
  for (var foodplace in foodplaces) {
    if (foodplace.uid == shop.foodPlace) {
      return foodplace.coordinates;
    }
  }
  return null;
}
