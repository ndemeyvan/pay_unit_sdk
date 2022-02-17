<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://payunit.net/wp-content/uploads/2020/11/PayUnit-logo.png" width="320" alt="Nest Logo" /></a>
</p>
  <p align="center">Welcome to <a href="https://payunit.net/" target="_blank"> The Pay Unit Flutter SDK </a>Seamlessly accept and manage payments in your app</p>
    <p align="center">
<a href="https://github.com/ndemeyvan/pay_unit_sdk" target="_blank"><img alt="Pub Version" src="https://img.shields.io/pub/v/pay_unit_sdk?color=%2308ADA4&style=for-the-badge" ></a>
<a><img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/ndemeyvan/pay_unit_sdk?color=%23F89623&style=for-the-badge"></a>
<a><img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/ndemeyvan/pay_unit_sdk?color=%2308ADA4&style=for-the-badge"></a>
<a href="" target="_blank"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/ndemeyvan/pay_unit_sdk?color=%23F89623&style=for-the-badge"></a>
<a><img alt="GitHub forks" src="https://img.shields.io/github/forks/ndemeyvan/pay_unit_sdk?color=%2300AB9F&style=for-the-badge"></a>
<a><img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/ndemeyvan/pay_unit_sdk?color=%23F89623&style=for-the-badge"></a>
<a href = "https://payunit.net/"><img alt="Website" src="https://img.shields.io/website?color=%2300AB9F&style=for-the-badge&up_color=00AB9F&up_message=Visit%20us&url=https%3A%2F%2Fpayunit.net%2Fdocs%2F"></a>
<a><img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/payunit7?color=%23F89623&&style=for-the-badge"></a>
<a href=""><img alt="Website" src="https://img.shields.io/website?color=%23F89623&label=Docs&style=for-the-badge&up_color=%23F89623&up_message=PHP%7CPYTHON%7CRESTAPI%7CJAVASCRIPT%7CWORDPRESS&url=https%3A%2F%2Fpayunit.net%2Fdocs%2F"></a>

</p>

# Description

[Pay Unit SDK ](https://payunit.net/) Package facilitates the intergration of payments on your applications with a single button and on the go.

# Installation

Run this command:

## With dart

```bash
dart pub add pay_unit_sdk 
```

## With Flutter

```bash
flutter pub add pay_unit_sdk
```

## Manually

```yaml
dependencies:
  pay_unit_sdk: ^3.0.2
  ```

## Import package

```dart
import 'package:pay_unit_sdk/pay_unit_sdk.dart';
```

## Add mavenCentral() to your project

- Add mavenCentral() to allprojects in gradle > build.gradle .

```gradle
allprojects {
    repositories {
        google()
        mavenCentral() <---
        jcenter()
    }
}
```

## Add the PayUnitButton

```dart
PayUnitButton(
              apiUser: "Your apiuser>",
              apiPassword:  "<Your apiPassword>",
              apiKey: "<Your apiKey>",
              transactionId: "<The id of your transaction>",
              mode: 'sandbox',
              transactionCallBackUrl:"<Your transactionCallBackUrl url>",
              notiFyUrl: "<Your notification url>",
              transactionAmount: "<Your transaction amount>",
              currency:"XAF", 
              buttonTextColor: Colors.white,
              productName:"<The name of the product>",
              color: Colors.teal
              actionAfterProccess: (transactionId, transactionStatus) {
               a callback that has both transaction id and transaction status
              },
          ),
```

# PayUnit Button Parameters

- apiUser : Your apiuser is provided on your payunit dashboard and looks like "payunit_xxxxxxxx"
- Mode : Your Mode can either be sandbox or live.
- Currency : The currency of your transaction : XAF for FCFA or USD for $ ect ...
- buttonTextColor: Custom the color of the text PayUnit button
- color : Use this to customise the colors of the PayUnit Button
- actionAfterProccess : here is the action who start after the end of the paiement , you can perform some operation here , like display a alertDialog after the end of the payment.
- transactionId and transactionStatus are callBack parameters of the actionAfterProccess function , don't modify them .

# Heads Up

- FOR FLUTTER VERSION < 2.x ==> 2.0.4 without Cupertino package because the package already has it
- Make sure the icon of your app is locate is like @mipmap/ic_launcher . to get the PayUnit sdk notification in your app after every transaction
- NEW Pay_unit_sdk VERSION 2.0.7 ==> Support Flutter 2.x
- To use this package, all you need to do is follow the instruction bellow, Please Download the recent version of the SDK
- minSdkVersion 19
- Use flutter sdk v.1.22.0 +

# Gallery

![gallery - Copy](https://user-images.githubusercontent.com/44162391/154532487-6d2723f3-8b9b-4b12-a534-8923205f51c5.png)

# Clients

<img width="1920" alt="clients - Copy" src="https://user-images.githubusercontent.com/44162391/154532588-496e4fd0-8d2e-443d-bd53-94814ff1f229.png">
