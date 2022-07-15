import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foodies/reusablewidgets.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinKitRotatingCircle(
              color: themeColour,
              size: 50.0,
            ),

            emptyBox(15),

            const Text("Loading...", style: TextStyle(fontSize: 13, color: Colors.black))
          ],
        ),
      ),
    );
  }
}
