# pay_unit_sdk

A new Flutter package.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

### Example
```dart
import 'package:eneopayappskeletteforsdk/PayButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Home(),
        ),
      );
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: PayUnitButton(
            text: "Payer",
            transactionId: '3062213443044409754311003546197686982579019697',
            transactionCallBackUrl: "https://eneocameroon.cm/index.php/en/",
            transonAmount: "1000",
            color: Colors.orange,
            actionAfterProccess: (){
              print(" Event after succes payment ");
            },
            merchandPassword: "payunit_TLYswhcCJ",
            merchandUserName: "0dc757b3-0abe-4b59-8523-e10d6f085897",
          ),
        )
      ],
    );
  }
}
