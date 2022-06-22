import 'package:flutter/material.dart';

import '../reusablewidgets.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  RangeValues _currentRange = const RangeValues(0, 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            emptyBox(50),

            //For slider
            Row(
              children: [
                const Icon(Icons.attach_money_rounded, size: 40),
                Expanded(
                    child: RangeSlider(
                        inactiveColor: Colors.teal,
                        activeColor: Colors.teal,
                        values: _currentRange,
                        min: 0,
                        max: 50,
                        divisions: 1,
                        labels: RangeLabels(
                            _currentRange.start.round().toString(),
                            _currentRange.end.round().toString()),
                        onChanged: (RangeValues range) {
                          setState(() => _currentRange = range);
                        }))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
