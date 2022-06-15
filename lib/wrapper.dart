import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'Login/all.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MainPage/all.dart';
import 'MainPage/sellermainpage.dart';
import 'Models/appuser.dart';
import 'Services/all.dart';
import 'loading.dart';

class Wrapper extends StatelessWidget {
  Wrapper({Key? key}) : super(key: key);
  final AuthService _auth = AuthService();
  final CollectionReference userInformation =
      FirebaseFirestore.instance.collection('UserInfo');

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    //return const LoginPage();
    if (user == null) {
      return const LoginPage();
    } else {
      return FutureBuilder(
            future: userInformation.doc(_auth.currentUser?.uid).get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data!.get('role').toString() == 'User') {
                  return const UserMainPage();
                }
                return const SellerMainPage();
              }
              return const Loading();
            });
    }
  }
}
