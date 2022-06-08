import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/ProfilePage/anonymouspage.dart';
import 'package:foodies/ProfilePage/sellerprofilepage.dart';
import 'package:foodies/ProfilePage/userprofilepage.dart';
import 'package:foodies/Services/all.dart';

import '../loading.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  final CollectionReference userInformation =
      FirebaseFirestore.instance.collection('UserInfo');

  //Check for anonymity, user or seller
  @override
  Widget build(BuildContext context) {
    return _auth.currentUser!.isAnonymous
        ? const AnonymousPage()
        : FutureBuilder(
            future: userInformation.doc(_auth.currentUser?.uid).get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data!.get('role').toString() == 'User') {
                  return const UserProfilePage();
                }
                return const SellerProfilePage();
              }
              return const Loading();
            });
  }
}
