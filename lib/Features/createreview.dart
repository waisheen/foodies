import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import 'package:foodies/reusablewidgets.dart';
import '../Models/review.dart';
import '../Models/shop.dart';
import '../loading.dart';
import 'package:bordered_text/bordered_text.dart';

import '../star.dart';

class CreateReviewPage extends StatefulWidget {
  const CreateReviewPage({Key? key, required this.shop, this.review})
      : super(key: key);
  final Review? review;
  final Shop shop;

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  //Create Review
  Future createReview(String? reviewID, String description, double rating,
      String shop, String user) async {
    reviewID == null
        ? await FirebaseFirestore.instance.collection('Review').add({
            'description': description,
            'rating': rating,
            'shop': shop,
            'user': user,
          })
        : await FirebaseFirestore.instance
            .collection('Review')
            .doc(reviewID)
            .set({
            'description': description,
            'rating': rating,
            'shop': shop,
            'user': user,
          });
  }

  //Variable states
  late String description =
      widget.review?.description == null ? '' : widget.review!.description;
  late double rating =
      widget.review?.rating == null ? 0.0 : widget.review!.rating;
  String update = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: backButton(context),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    emptyBox(125.0),

                    //sign up text
                    Center(
                      child: BorderedText(
                        strokeColor: Colors.green,
                        strokeWidth: 2.0,
                        child: const Text(
                          'Review',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 55.0,
                          ),
                        ),
                      ),
                    ),

                    emptyBox(25.0),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: StarRating(
                          rating: rating,
                          onRatingChanged: (rating) =>
                              setState(() => this.rating = rating)),
                    ),

                    emptyBox(10),

                    //enter description
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: TextFormField(
                            maxLines: 5,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 40, horizontal: 20),
                              border: OutlineInputBorder(),
                              labelText: "Description",
                              hintText: "Enter a short description",
                            ),
                            initialValue: description,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Cannot be empty';
                              }
                              if (val.length > 500) {
                                return 'Max Length: 500 characters';
                              }
                              return null;
                            },
                            onChanged: (val) =>
                                setState(() => description = val))),

                    emptyBox(15.0),
                    //create account  button
                    bigButton(
                        widget.review == null ? "Create Review" : 'Edit Review',
                        () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => loading = true);
                        dynamic result = await createReview(
                            widget.review?.uid,
                            description,
                            rating,
                            widget.shop.uid,
                            _auth.currentUser!.uid);

                        if (result == null) {
                          setState(() => update = 'Updated');
                          setState(() => loading = false);
                        }
                      }
                    }),

                    emptyBox(10.0),

                    Text(
                      update,
                      style:
                          const TextStyle(color: Colors.green, fontSize: 15.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
