import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/reusablewidgets.dart';
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
  final Promotion? promo;

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
            extendBodyBehindAppBar: true,
            appBar: backButton(context),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    emptyBox(125.0),

                    //Promotion
                    Center(
                      child: BorderedText(
                        strokeColor: Colors.teal,
                        strokeWidth: 2.0,
                        child: const Text(
                          'Promotion',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 55.0,
                          ),
                        ),
                      ),
                    ),

                    emptyBox(25.0),

                    //enter details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        maxLines: 10,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
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

                    SizedBox(
                      width: MediaQuery.of(context).size.width - 60,
                      child: const Text(
                        "Promotional Period:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),

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
                      ]
                    ),

                    emptyBox(30.0),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        maxLines: 2,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
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
                        dynamic result = await createPromotion(
                            details, startDate, endDate, imageURL, shopID);

                        if (result == null) {
                          if (!mounted) return;
                          Navigator.pop(context);
                        }
                      }
                    }),

                    emptyBox(20.0),

                    hasPromo
                        ? bigButton("Delete Promotion", () async {
                            dynamic result = await deletePromotion();

                            if (result == null) {
                              if (!mounted) return;
                              Navigator.pop(context);
                            }
                          })
                        : emptyBox(1.0),

                    emptyBox(50.0),
                  ],
                ),
              ),
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

  Widget showImage(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Image(
        image: NetworkImage(url),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            (url == '' ? 'No image uplaoded' : 'Image cannot be shown'),
            style: const TextStyle(fontSize: 15),
          );
        },
      ),
    );
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
