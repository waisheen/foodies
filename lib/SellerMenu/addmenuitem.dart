import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodies/reusablewidgets.dart';
import 'package:foodies/theme.dart';
import '../Models/menu.dart';
import '../Models/shop.dart';
import '../loading.dart';
import 'package:bordered_text/bordered_text.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart';

class AddMenuItemPage extends StatefulWidget {
  const AddMenuItemPage({Key? key, required this.shop, this.item})
      : super(key: key);
  final Shop? shop;
  final Menu? item;

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();

  //Variable states
  late String name = widget.item == null ? '' : widget.item!.name;
  late double price = widget.item == null ? 0 : widget.item!.price;
  late String imageURL = widget.item == null ? '' : widget.item!.imageURL;
  late String shopID = widget.shop!.uid;

  bool loading = false;
  late bool hasItem = widget.item != null;
  late String priceString = widget.item == null ? "0.00" : widget.item!.price.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return loading
    ? const Loading()
    : Scaffold(
        // extendBodyBehindAppBar: false,
        // appBar: backButton(context),
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [ 
            sliverAppBar(context, "Menu Item"),

            SliverList(
              delegate: SliverChildListDelegate(
              [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      //Menu Item
                      // Center(
                      //   child: BorderedText(
                      //     strokeColor: themeColour,
                      //     strokeWidth: 2.0,
                      //     child: const Text(
                      //       'Menu Item',
                      //       style: TextStyle(
                      //         color: Colors.transparent,
                      //         fontSize: 55.0,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      emptyBox(20),
                          
                      heading(context, "Enter item:"),

                      //enter name
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30, top: 15),
                        child: TextFormField(
                          // maxLines: 2,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            border: OutlineInputBorder(),
                            labelText: "Name",
                            hintText: "Enter name of item",
                          ),
                          initialValue: name,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Cannot be empty';
                            }
                            if (val.length > 100) {
                              return 'Max Length: 100 characters';
                            }
                            return null;
                          },
                          onChanged: (val) => setState(() => name = val),
                        ),
                      ),

                      emptyBox(30.0),

                      heading(context, "Enter price:"),

                      //enter price
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30, top: 15),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          // inputFormatters: <TextInputFormatter>[
                          //   FilteringTextInputFormatter.
                          // ],
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            border: OutlineInputBorder(),
                            labelText: "Price",
                            hintText: "Enter price",
                            prefixText: "\$ "
                          ),
                          initialValue: priceString,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Cannot be empty';
                            }
                            try {
                              double.parse(val);
                              return null;
                            } catch (e) {
                              return 'Enter only numbers';
                            }
                          },
                          onChanged: (val) => setState(() {
                            double newPrice = double.parse(val);
                            priceString = newPrice.toStringAsFixed(2);
                            price = newPrice;
                          }),
                        ),
                      ),

                      emptyBox(30.0),

                      heading(context, "Enter image link:"),

                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30, top: 15),
                        child: TextFormField(
                          maxLines: 2,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            border: OutlineInputBorder(),
                            labelText: "Image",
                            hintText: "Enter link of menu item",
                          ),
                          initialValue: imageURL,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                          onChanged: (val) => setState(() => imageURL = val),
                        ),
                      ),

                      emptyBox(15.0),

                      showImage(imageURL),

                      emptyBox(30.0),

                      //create Promotion button
                      bigButton(hasItem ? "Save Changes" : 'Add Menu Item',
                          () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          dynamic result = await addItem(name, price, imageURL, shopID);

                          if (result == null) {
                            if (!mounted) return;
                            Navigator.pop(context);
                          }
                        }
                      }),

                      emptyBox(20.0),

                      hasItem
                      ? bigButton(
                        "Delete Item", 
                        () => confirmationPopUp(
                          context, 
                          "Are you sure you want to delete this item?",
                          () async {
                            dynamic result = await deleteItem();

                            if (result == null) {
                              if (!mounted) return;
                              Navigator.pop(context);
                            }
                          },
                        ),
                      )
                      : emptyBox(1.0),

                      emptyBox(50.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //create Promotion
  Future addItem(String name, double price, String imageURL, String shopID) async {
    hasItem
        ? await FirebaseFirestore.instance
            .collection('Menu')
            .doc(widget.item!.uid)
            .set({
            'name': name,
            'price' : price,
            'imageURL': imageURL,
            'shop': shopID
          })
        : await FirebaseFirestore.instance.collection('Menu').add({
            'name': name,
            'price' : price,
            'imageURL': imageURL,
            'shop': shopID
          });
  }

  //delete item
  Future deleteItem() async {
    await FirebaseFirestore.instance
        .collection('Menu')
        .doc(widget.item!.uid)
        .delete();
  }
}
