import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  List<String> cuisineList = [
    'Chinese',
    'Malay',
    'Indian',
    'Western',
    'Japanese',
    'Korean',
    'Drinks',
    'Others'
  ];

  //Variable states
  late String name =  widget.shop!.name;
  late int opening =  widget.shop!.opening;
  late int closing =  widget.shop!.closing;
  late List<String> openDays =  widget.shop!.openDays;
  late String imageURL =  widget.shop!.imageURL;
  late String cuisine = '';
  late bool halal = false;
  late bool vegetarian = false;

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
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                //backdrop image
                showImage(imageURL),

                //profile picture
                const Positioned(
                  bottom: -70,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(
                          "https://m.media-amazon.com/images/M/MV5BNGFhZWFhMjAtOTU1Yy00NTk1LThmZDMtYzZiMGM4NzkyZTlhL2ltYWdlL2ltYWdlXkEyXkFqcGdeQXVyNDk2NDYyMTk@._V1_.jpg"),
                    ),
                  ),
                ),
              ],
            ),

            emptyBox(90),

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
            
            GestureDetector(
                onTap: () {},
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(widget.shop!.operatingHours,
                  style: const TextStyle(fontSize: 16))
                ),
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
                  items: cuisineList
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (val) {
                    if (val == null || (!cuisineList.contains(val))) {
                      return 'Choose a cuisine';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() => cuisine = val.toString());
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
                  dietButton(halal, "Halal", () => setState(() => halal = !halal)),
                  dietButton(vegetarian, "Vegetarian", () => setState(() => vegetarian = !vegetarian))
                ]
              ),
            ),

            emptyBox(20),

            bigButton("Save Changes",
                        () async {
                      // if (_formKey.currentState!.validate()) {
                      //   setState(() => loading = true);
                      //   dynamic result = await createPromotion(
                      //       details,
                      //       startDate,
                      //       endDate,
                      //       imageURL,
                      //       shopID);

                      //   if (result == null) {
                      //     if (!mounted) return;
                      //     Navigator.pop(context);
                      //   }
                      // }
                    }),

            emptyBox(20)
          ],
        ),
      ),
    );
  }

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
              daysSelected[index] = !daysSelected[index];
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

}
