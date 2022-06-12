import 'package:flutter/material.dart';

Color setColor(int index) {
  if (index == 0) {
    return Colors.blue;
  } else if (index == 1) {
    return Colors.red;
  } else if (index == 2) {
    return Colors.green;
  } else if (index == 2) {
    return Colors.amber;
  } else {
    return Colors.purple;
  }
}
