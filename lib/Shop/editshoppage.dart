// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Shop/shopdetails.dart';
import 'package:foodies/reusablewidgets.dart';
import '../Models/promotion.dart';
import '../Models/shop.dart';
import '../loading.dart';
import 'package:bordered_text/bordered_text.dart';

class EditShopPage extends StatefulWidget {
  const EditShopPage({Key? key, required this.shop}) : super(key: key);
  final Shop? shop;

  @override
  State<EditShopPage> createState() => _EditShopPageState();
}

class _EditShopPageState extends State<EditShopPage> {
  final _formKey = GlobalKey<FormState>();
  List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  late Shop? shop = widget.shop;

  //Variable states
  late String name =  shop!.name;
  late int opening =  shop!.opening;
  late int closing =  shop!.closing;
  late List<String> openDays =  shop!.openDays;
  late String imageURL =  shop!.imageURL;
  late List<String> options = shop!.options;

  bool loading = false;
  late List<bool> daysSelected = allDays.map((day) {
    return widget.shop!.openDays.contains(day);
  }).toList();


  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: backButton(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
        child: Form(
            key: _formKey,
            child: Column(
            children: <Widget>[
              //backdrop image
              showImage(imageURL),

              emptyBox(40),

              //edit shop imageURL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextFormField(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      border: OutlineInputBorder(),
                      labelText: "Image",
                    ),
                    initialValue: imageURL,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Cannot be empty';
                      }
                      return null;
                    },
                    onChanged: (val) =>
                        setState(() => imageURL = val),
                ),
              ),

              emptyBox(15),

              //edit shop name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextFormField(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      border: OutlineInputBorder(),
                      labelText: "Shop Name",
                    ),
                    initialValue: name,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Cannot be empty';
                      }
                      return null;
                    },
                    onChanged: (val) =>
                        setState(() => name = val),
                ),
              ),

              emptyBox(15),

              //edit Opening Days
              ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Opening Days"),
                ),
                subtitle: Row(
                  children: allDays
                      .map((day) =>
                          dayButton(allDays.indexOf(day), day.substring(0, 3)))
                      .toList()),
              ),

              //display opening hours
              const ListTile(
                contentPadding: EdgeInsets.only(left: 25),
                title: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Opening Hours"),
                ),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 1),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(
                        color: Colors.grey, 
                        width: 1.0, // Underline thickness
                        ))
                      ),
                    child: GestureDetector(
                      onTap: () async {
                        int newTime = await chooseTime(opening);
                        setState(() {
                          opening = newTime;
                        });                 
                      },
                      child: SizedBox(
                        child: Text(convertIntToTime(opening),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const Text("  -  "),

                  Container(
                    padding: const EdgeInsets.only(bottom: 1),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(
                        color: Colors.grey, 
                        width: 1.0, // Underline thickness
                        ))
                      ),
                    child: GestureDetector(
                      onTap: () async {
                        int newTime = await chooseTime(closing);
                        setState(() {
                          closing = newTime;
                        });                 
                      },
                      child: SizedBox(
                        child: Text(convertIntToTime(closing),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              

              //display minmax prices
              ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Prices"),
                ),
                subtitle: Text(
                    '\$${widget.shop!.minPrice} to \$${widget.shop!.maxPrice}', //get number from database
                    style: const TextStyle(fontSize: 16)), 
              ),

              //display foodplace
              ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Location"),
                ),
                subtitle: widget.shop!.foodPlaceText(context, 16),
              ),

              //choose cuisine
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Cuisine"),
                ),
                subtitle: DropdownButtonFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder()
                    ),
                    hint: const Text('Choose cuisine'),
                    items: widget.shop!.cuisineList
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (val) {
                      if (val == null || (!widget.shop!.cuisineList.contains(val))) {
                        return 'Choose a cuisine';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() => toggleOptions(val.toString()));
                    },
                  ),  
              ),

              emptyBox(10),

              //edit dietary requirements
              ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Food is:"),
                ),
                subtitle: Row(
                  children: [
                    dietButton(isHalal(options), "Halal", () => setState(() => toggleOptions("halal"))),
                    dietButton(isVegetarian(options), "Vegetarian", () => setState(() => toggleOptions("vegetarian")))
                  ]
                ),
              ),

              emptyBox(20),

              bigButton("Save Changes",() async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          dynamic result = await editShop(name, openDays, opening, closing, options);

                          if (result == null) {
                            if (!mounted) return;
                            Navigator.pop(context);
                          }
                        }
                      }),

              emptyBox(20)
            ],
          ),
        ), 
      ),
    );
  }

  //previews image from imageURL entered 
  Widget showImage(String url) {
    return Image(
      image: NetworkImage(url),
      height: MediaQuery.of(context).size.height / 4,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: const Align(
            alignment: Alignment.center,
            child: Text("Unable to display image", 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
              ),
          ),
        );
      },
    );
  }

  Widget dayButton(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.5, right: 5),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: daysSelected[index] ? Colors.green : Colors.white,
            border: Border.all(color: daysSelected[index] ? Colors.black : Colors.grey)),
        height: 35,
        width: 45,
        child: TextButton(
          onPressed: () {
            setState(() {
              //edit daysSelect list
              daysSelected[index] = !daysSelected[index];
              updateDays();
            });
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: daysSelected[index] ? Colors.black : Colors.grey, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget dietButton(bool selected, String text, void Function()? onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.5, right: 5),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: selected ? Colors.green : Colors.white,
            border: Border.all(color: selected ? Colors.black : Colors.grey)),
        height: 35,
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: selected ? Colors.black : Colors.grey, fontSize: 12),
          ),
        ),
      ),
    );
  }

  //toggles options list
  void toggleOptions(String option) {
    if (option == "halal") {
      isHalal(options) ? options.remove(option) : options.add(option);
    } else if (option == "vegetarian") {
      isVegetarian(options) ? options.remove(option) : options.add(option);
    } else {
      String currCuisine = getCuisine(options);
      options.remove(currCuisine);
      options.add(option);
    }
  }

  //select time
  Future<int> chooseTime(int time) async {
    TimeOfDay initialTime = TimeOfDay(hour: time ~/ 100, minute: time % 100);
    TimeOfDay? newTime = await showTimePicker(
      context: context, 
      initialTime: initialTime);

    if (newTime != null) {
      return newTime.hour * 100 + newTime.minute;
    }
    return time;
  }

  void updateDays() {
    //edit openDays list
    List<String> newList = [];
    for (int i in [0, 1, 2, 3, 4, 5, 6]) {
      if (daysSelected[i]) {
        newList.add(allDays[i]);
      }
    }
    openDays = newList;
  }

  //edit shop
  Future editShop(String name, List<String> openDays, int opening, int closing, 
      List<String> options) async {
    return await FirebaseFirestore.instance
      .collection('Shop')
      .doc(widget.shop!.uid)
      .update({
      'name': name,
      'openDays': openDays,
      'opening': opening,
      'closing': closing,
      'options': options
      });
  }

}
