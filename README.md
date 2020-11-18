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

## To use this package, all you need to do is apply the PayUnitButton button in your widget and enter the requested information as a parameter as in the example below.
```

import 'dart:math';
import 'package:eneopayappskeletteforsdk/PayButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(App());

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Home(),
    ),
  );

}

var uuid = Uuid();

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: 

	PayUnitButton(
            text: "Payer",
            X_API_KEY: "X_API_KEY",
            transactionCallBackUrl: "transactionCallBackUrl",
            transonAmount: "transonAmount",
            color: Colors,
            merchandUserName: "merchandUserName",
            merchandPassword: "merchandPassword",
            actionAfterProccess: (){
             //Code to run after the transaction is successful
            },
          ),

        )
      ],
    );
  }

}

```
