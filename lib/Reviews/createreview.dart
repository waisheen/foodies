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
  Future createReview(Review? review, String description, double rating,
      Shop shop, String user) async {
    !hasReview
        ? await FirebaseFirestore.instance.collection('Review').add({
            'description': description,
            'rating': rating,
            'shop': shop.uid,
            'user': user,
          })
        : await FirebaseFirestore.instance
            .collection('Review')
            .doc(review!.uid)
            .set({
            'description': description,
            'rating': rating,
            'shop': shop.uid,
            'user': user,
          });
    !hasReview
        ? await FirebaseFirestore.instance
            .collection('Shop')
            .doc(shop.uid)
            .update({
            'totalRating': shop.totalRating + rating,
            'totalReview': shop.totalReview + 1,
          })
        : await FirebaseFirestore.instance
            .collection('Shop')
            .doc(shop.uid)
            .update({
            'totalRating': shop.totalRating + rating - review!.rating,
          });
  }

  //Variable states
  late String description =
      widget.review?.description == null ? '' : widget.review!.description;
  late double rating =
      widget.review?.rating == null ? 0.0 : widget.review!.rating;
  bool loading = false;
  late bool hasReview = widget.review != null;

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
                    
                    //create review button
                    bigButton(!hasReview ? "Create Review" : 'Save Changes',
                        () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => loading = true);
                        dynamic result = await createReview(
                            widget.review,
                            description,
                            rating,
                            widget.shop,
                            _auth.currentUser!.uid);

                        if (result == null) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          successFlushBar(
                            context, 
                            hasReview ? "Changes saved" : "Review created", 
                            true);
                        }
                      }
                    }),

                    emptyBox(20.0),
                  ],
                ),
              ),
            ),
          );
  }
}