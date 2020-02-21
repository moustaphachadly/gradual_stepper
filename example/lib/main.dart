import 'package:flutter/material.dart';
import 'package:gradual_stepper/gradual_stepper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradual Stepper Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: GradualStepper(
            initialValue: 0,
            minimumValue: -100,
            maximumValue: 100,
            stepValue: 2,
            onChanged: (int value) => print('new value $value'),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
