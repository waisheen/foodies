import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/reusablewidgets.dart';
import 'package:foodies/theme.dart';
import '../Models/promotion.dart';
import '../Models/shop.dart';
import '../loading.dart';
import 'package:bordered_text/bordered_text.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:intl/intl.dart';

class CreatePromotionPage extends StatefulWidget {
  const CreatePromotionPage({Key? key, required this.shop, this.promo})
      : super(key: key);
  final Shop shop;
  final Menu? promo;

  @override
  State<CreatePromotionPage> createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends State<CreatePromotionPage> {
  final _formKey = GlobalKey<FormState>();

  //Variable states
  late String details = widget.promo == null ? '' : widget.promo!.details;
  late String imageURL = widget.promo == null ? '' : widget.promo!.imageURL;
  late String shopID = widget.shop.uid;
  late DateTime startDate =
      widget.promo == null ? DateTime.now() : widget.promo!.startDate;
  late DateTime endDate =
      widget.promo == null ? DateTime.now() : widget.promo!.endDate;

  bool loading = false;
  late bool hasPromo = widget.promo != null;

  @override
  Widget build(BuildContext context) {
    return loading
      ? const Loading()
      : Scaffold(
          // extendBodyBehindAppBar: false,
          // appBar: backButton(context),
          backgroundColor: Colors.white,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              sliverAppBar(context, "Promotion"),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          //Promotion
                          // Center(
                          //   child: BorderedText(
                          //     strokeColor: themeColour,
                          //     strokeWidth: 2.0,
                          //     child: const Text(
                          //       'Promotion',
                          //       style: TextStyle(
                          //         color: Colors.transparent,
                          //         fontSize: 55.0,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          emptyBox(20),
                          heading(context, "Enter description:"),

                          //enter details
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, right: 30, top: 15),
                            child: TextFormField(
                              maxLines: 10,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                border: OutlineInputBorder(),
                                labelText: "Description",
                                hintText: "Enter promotional details",
                              ),
                              initialValue: details,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Cannot be empty';
                                }
                                if (val.length > 1000) {
                                  return 'Max Length: 1000 characters';
                                }
                                return null;
                              },
                              onChanged: (val) => setState(() => details = val),
                            ),
                          ),

                          emptyBox(15.0),

                          heading(context, "Promotional Period:"),

                          emptyBox(15.0),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: chooseDate,
                                  child: Text(
                                    "${dateFromDateTime(startDate)}  -  ${dateFromDateTime(endDate)}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ]),

                          emptyBox(30.0),

                          heading(context, "Enter image link:"),

                          //enter imageURL
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, right: 30, top: 15),
                            child: TextFormField(
                              maxLines: 2,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                border: OutlineInputBorder(),
                                labelText: "Image",
                                hintText: "Enter link of promotional image",
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
                          bigButton(hasPromo ? "Save Changes" : 'Create Promotion',
                              () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              dynamic result = await createPromotion(details,
                                  startDate, endDate, imageURL, shopID);

                              if (result == null) {
                                if (!mounted) return;
                                Navigator.pop(context);
                              }
                            }
                          }),

                          emptyBox(20.0),

                          hasPromo
                          ? bigButton("Delete Promotion", 
                            () => confirmationPopUp(
                              context, 
                              "Are you sure you want to delete this promotion?",
                              () async {
                                dynamic result = await deletePromotion();

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

  void chooseDate() async {
    DateTimeRange? dateRange = await showDateRangePicker(
        context: context, firstDate: DateTime(2000), lastDate: DateTime(2100));

    if (dateRange != null) {
      setState(() {
        startDate = dateRange.start;
        endDate = dateRange.end;
      });
    }
  }

  //create Promotion
  Future createPromotion(String details, DateTime startDate, DateTime endDate,
      String imageURL, String shopID) async {
    hasPromo
        ? await FirebaseFirestore.instance
            .collection('Promotion')
            .doc(widget.promo!.uid)
            .set({
            'details': details,
            'startDate': startDate,
            'endDate': endDate,
            'imageURL': imageURL,
            'shop_id': shopID
          })
        : await FirebaseFirestore.instance.collection('Promotion').add({
            'details': details,
            'startDate': startDate,
            'endDate': endDate,
            'imageURL': imageURL,
            'shop_id': shopID
          });
  }

  //delete promotion
  Future deletePromotion() async {
    await FirebaseFirestore.instance
        .collection('Promotion')
        .doc(widget.promo!.uid)
        .delete();
  }
}
