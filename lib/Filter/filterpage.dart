import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Filter/filteredshops.dart';
import 'package:foodies/Models/nus_location.dart';
import 'package:awesome_select/awesome_select.dart';

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
                        const Icon(
                          Icons.attach_money_rounded,
                          size: 35,
                          color: Colors.teal,
                        ),
                        Expanded(
                            child: RangeSlider(
                                inactiveColor: Colors.teal,
                                activeColor: Colors.teal,
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
                              hint: const Text('All'),
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
                            modalHeaderStyle: const S2ModalHeaderStyle(
                                backgroundColor: Colors.teal),
                            onChange: (selected) {
                              setState(
                                  () => _selectedOptions = selected!.value!);
                            },
                            choiceItems: _foodOptions
                                .map((string) => S2Choice<String>(
                                    title: string, value: string))
                                .toList(),
                            choiceType: S2ChoiceType.switches,
                            choiceActiveStyle: const S2ChoiceStyle(
                              color: Colors.teal,
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
                    shops = shops
                        .where((shop) => shop.options
                            .any((opt) => _selectedOptions.contains(opt)))
                        .toList();
                    setState(() => loading = false);

                    if (!mounted) return;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FilteredShopsPage(
                                  shopList: shops,
                                )));
                  })
                ],
              ),
            ),
          );
  }
}
