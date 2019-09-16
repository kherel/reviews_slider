import 'package:flutter/material.dart';
import 'package:reviews_slider/reviews_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedValue;

  void onChange(int value) {
    setState(() {
      selectedValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SafeArea(
          /// shoud be run on a big screen
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 500,
                child: Text(
                  'Price',
                  style: TextStyle(fontSize: 40, height: 1.5),
                ),
              ),
              Expanded(
                child: ReviewSlider(
                  onChange: onChange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
