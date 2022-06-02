import 'package:flutter/material.dart';

Widget emptyBox(double height) {
  return SizedBox(height: height);
}

//user to input text field
Widget inputText(String label, String hint, Widget icon, String? Function(String?)? validator, void Function(String)? onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: TextFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hint,
        prefixIcon: icon,
      ),
      validator: validator,
      onChanged: onChanged
    ),
  );
}

//back button 
PreferredSizeWidget backButton(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: TextButton.icon(
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
      /*label: const Text(
    'Back',
    style: TextStyle(color: Colors.black),
  ),*/
      onPressed: () => Navigator.pop(context),
      label: Container(),
    ),
  );
}

//big buttons 
Widget bigButton(String text, void Function()? onPressed) {
  return Container(
    height: 50.0,
    width: 250.0,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.teal),
    ),
    child: TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black, 
          fontSize: 16),
      ),
    ),
  );
}