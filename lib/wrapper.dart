import 'package:provider/provider.dart';
import 'Login/all.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MainPage/all.dart';
import 'Models/appuser.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    //return const LoginPage();
    if (user == null) {
      return const LoginPage();
    } else {
      return const MainPage();
    }
  }
}
