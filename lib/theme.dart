import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodies/reusablewidgets.dart';
import 'package:google_fonts/google_fonts.dart';

//Edit for theme data
ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.openSans().fontFamily,
    appBarTheme: AppBarTheme(
        color: themeColour,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        toolbarTextStyle:
            const TextStyle(color: Color(0XFF8B8B8B), fontSize: 18)),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // textTheme: textTheme()
  );
}

TextTheme textTheme() {
  return const TextTheme(
      bodyText1: TextStyle(color: Color(0xFF757575)),
      bodyText2: TextStyle(color: Color(0xFF757575)));
}
