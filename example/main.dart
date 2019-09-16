import 'package:flutter/material.dart';
import 'package:reviews_slider/reviews_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedValue1;
  int selectedValue2;

  int onChange1(int value) {
    setState(() {
      selectedValue1 = value;
    });
    return 5;
  }

  void onChange2(int value) {
    setState(() {
      selectedValue2 = value;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'How was the help you recived?',
                style: TextStyle(color: Color(0xFF6f7478), fontSize: 18),
              ),
              SizedBox(height: 20),
              ReviewSlider(
                onChange: onChange1,
              ),
              Text(selectedValue1.toString()),
              SizedBox(height: 20),
              Text(
                'How was the help you recived?',
                style: TextStyle(color: Color(0xFF6f7478), fontSize: 18),
              ),
              SizedBox(height: 20),
              ReviewSlider(
                  optionStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  onChange: onChange2,
                  initialValue: 1,
                  options: ['Ужасно', 'Плохо', 'Пойдет', 'Хорошо', 'Отлично']),
              Text(selectedValue2.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
