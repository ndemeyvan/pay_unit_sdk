import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pusher_websocket_flutter/pusher.dart';
import '../pay_unit_sdk.dart';
import 'blocs/PayUnitStream.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:native_progress_hud/native_progress_hud.dart';
import './Constant/Constant.dart'as constant;

class ApiService {
  Channel channel;

  /// [context] : the actual context of the app
  /// [X_API_KEY] : the x-api-key
  /// [transactionAmount] : the amount you want to pay
  /// [transactionCallBackUrl] : your callBack url
  initiatePayment({
    @required context,
    @required String X_API_KEY,
    @required String productName,
    @required String transactionAmount,
    @required String transactionCallBackUrl,
    @required String description,
    @required merchandUserName,
    @required transaction_id,
    @required merchandPassword,
    @required sandbox,
    @required Function actionAfterProccess,
  }) async {
    try {
      //initiation pusher
      await initPusher(transaction_id, actionAfterProccess, context);
      // await initializeNotifications();
      print("is sandbox : $sandbox");
      var data = jsonEncode({
        "description": description,
        "transaction_id": transaction_id,
        "total_amount": transactionAmount,
        "return_url": "https://eneocameroon.cm/index.php/en/"
      });
      print("this is data send to server : $data");
      var jsonResponse;

      var response = await getDigestAuth(merchandUserName, merchandPassword).post(
          "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/initialize",
          body: data,
          headers: getGlobalHeader(X_API_KEY));
      jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse != null) {
          // print(" 201 ou 200 response /initiate : ${response.body}");
          payUnitStream.setListProviderSink.add(await getAllProviders(
            context: context,
            transactionId: jsonResponse['t_id'],
            transactionAmount: jsonResponse['t_sum'],
            transactionCallBackUrl: jsonResponse['t_url'],
            merchandPassword: merchandPassword,
            merchandUserName: merchandUserName,
            X_API_KEY: X_API_KEY,
            sandbox: sandbox,
          ));
        }
      } else {
        print("Else bloc in initiatePayment : $jsonResponse");
        constant.makeToast(jsonResponse['error'], context, Colors.red);
      }
    } catch (e) {
      print("InitiatePayment catchError : $e");
      constant.makeToast("Something went wrong , please try again or later",
          context, Colors.red);
    } finally {
      closeDialog(context);
    }
  }

  /// [context] : the actual context of the app
  /// [transactionId] : the amount of the bill
  /// [transactionAmount] : the amount you want to pay
  /// [transactionCallBackUrl] : your callBack url
  getAllProviders({
    context,
    @required String transactionId,
    @required String transactionAmount,
    @required String transactionCallBackUrl,
    @required String merchandUserName,
    @required String merchandPassword,
    @required String X_API_KEY,
    @required String sandbox,
  }) async {
    try {
      var jsonResponse;
      var response = await getDigestAuth(merchandUserName, merchandPassword).get(
          "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/gateways?t_id=$transactionId&t_sum=$transactionAmount&t_url=$transactionCallBackUrl",
          headers: getGlobalHeader(X_API_KEY));
      jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse != null) {
          // print(" 200 response /providers : $jsonResponse");
          return json.decode(response.body)['data'];
        }
      } else {
        if (jsonResponse != null) {
          print(" Else response /providers : $jsonResponse");
          closeDialog(context);
          return [];
        }
      }
    } catch (e) {
      print(" catch error /providers : ${e}");
      closeDialog(context);
      constant.makeToast("Something went wrong , please try again or later",
          context, Colors.red);
    } finally {
      closeDialog(context);
    }
  }

  /// [context] : the actual context of the app
  /// [transactionId] : the amount of the bill
  /// [transactionAmount] : the amount you want to pay
  /// [transactionCallBackUrl] : your callBack url
  getPaymentStatus({
    @required context,
    @required String transactionId,
    @required String paymentRef,
    @required String payToken,
    @required String merchandUserName,
    @required String merchandPassword,
    @required String provider_short_tag,
    @required Function actionAfterProccess,
    @required String X_API_KEY,
    @required String sandbox,
  }) async {
    try {
      print(" is sandbox ? /getPaymentStatus: $sandbox");
      print("I am waiting for push notification ");
      // callback;
      const time = const Duration(seconds: 4);
      Timer _timer;
      _timer = new Timer.periodic(time, (Timer timer) async {
        var jsonResponse;
        var response = await getDigestAuth(merchandUserName, merchandPassword).get(
            "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/paymentstatus/$provider_short_tag/$transactionId?payment_ref=${paymentRef}&pay_token=${payToken}",
            headers: getGlobalHeader(X_API_KEY));
        // jsonResponse = json.decode(response.body);
        if (response.statusCode == 200) {
          // print(" 200 response /getPaymentStatus : $jsonResponse");
          _timer.cancel();

          // if (jsonResponse != null) {
          //   print(" 200 response /getPaymentStatus : $jsonResponse");
          //   if (jsonResponse['status'] == "PENDING") {
          //     // the payment is pending , wait for another timer period
          //   } else if (jsonResponse['status'] == "SUCCESSFUL") {
          //     _timer.cancel();
          //     // constant.succesPaymentDialog("Payment success", context,
          //     //     "Thank using Payunit payment", actionAfterProccess);
          //     // unSubscribePusher(transactionId);
          //     // unbindEvent();
          //   } else {
          //     _timer.cancel();
          //     // payUnitStream.paymentSink.addError("error");
          //   }
          // }

        } else {
          if (jsonResponse != null) {
            print(" Else response /getPaymentStatus : $jsonResponse");
            constant.makeToast(jsonResponse['error'], context, Colors.red);

            closeDialog(context);
            _timer.cancel();
            // payUnitStream.paymentSink.addError("error");
          }
        }
      });
    } catch (e) {
      print(" catch error /providers : ${e}");
      // closeDialog(context);
      constant.makeToast("Something went wrong , please try again or later",
          context, Colors.red);
    } finally {
      // closeDialog(context);
    }
  }

  /// [context] : the actual context of the app
  /// [transactionId] : the amount of the bill
  /// [transactionAmount] : the amount you want to pay
  /// [transactionCallBackUrl] : your callBack url
  /// [provider_short_tag] : the tag of the provider
  /// [phoneNumber] : the phone number of the client
  /// [userName] : the user name of the client
  makePayment({
    @required context,
    @required String X_API_KEY,
    @required String transactionAmount,
    @required String transactionCallBackUrl,
    @required String provider_short_tag,
    @required String phoneNumber,
    @required Function actionAfterProccess,
    @required String userName,
    @required merchandUserName,
    @required transaction_id,
    @required merchandPassword,
    @required sandbox,
    @required currency,
  }) async {
    var response;
    var data = currency != null
        ? jsonEncode({
      'gateway': provider_short_tag,
      'amount': transactionAmount,
      'transaction_id': transaction_id,
      'return_url': transactionCallBackUrl,
      'phone_number': phoneNumber,
      'description': "Pay unit flutter sdk",
      "name": provider_short_tag,
      "currency": currency,
    })
        : jsonEncode({
      'gateway': provider_short_tag,
      'amount': transactionAmount,
      'transaction_id': transaction_id,
      'return_url': transactionCallBackUrl,
      'phone_number': phoneNumber,
      'description': "Pay unit flutter sdk",
      "name": provider_short_tag,
    });
    print("Environnement : $sandbox");

    try {
      print("this is sending data : $data");
      var jsonResponse;
      if (provider_short_tag == 'mtnmomo' || provider_short_tag == 'orange') {
        constant.closeAndToastPaymentAreMake(context);
        response = await getDigestAuth(merchandUserName, merchandPassword).post(
            "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/makepayment",
            body: data,
            headers: getGlobalHeader(X_API_KEY));
      } else if (provider_short_tag == 'eu') {
        constant.closeAndToastPaymentAreMake(context);
        response = await getDigestAuth(merchandUserName, merchandPassword).post(
            "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/makepayment",
            body: data,
            headers: getGlobalHeader(X_API_KEY));
      } else if (provider_short_tag == 'stripe' ||
          provider_short_tag == 'paypal') {
        progressHub("Please wait", context);
        response = await getDigestAuth(merchandUserName, merchandPassword).post(
            "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/makepayment",
            // "${sandbox =='sandbox' ? constant.baseUrlSandBox : constant.baseUrl }/payments/gateway/makepayment",
            body: data,
            headers: getGlobalHeader(X_API_KEY));
      }
      print("Global response /makePayment : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        // print("200 response /makePayment : ${json.decode(response.body)}");
        constant.makeToast(
            json.decode(response.body)['message'], context, Colors.green);
        jsonResponse = json.decode(response.body)["data"];
        if (provider_short_tag == 'stripe') {
          var obj = {
            "secret_key": jsonResponse["secret_key"],
            "publishable_key": jsonResponse["publishable_key"]
          };
          return obj;
        }
        if (provider_short_tag == 'paypal') {
          closeDialog(context);
          var obj = {"order_id": jsonResponse["order_id"]};
          return obj;
        }
        getPaymentStatus(
            transactionId: transaction_id,
            paymentRef: jsonResponse["payment_ref"],
            payToken: jsonResponse["pay_token"],
            merchandUserName: merchandUserName,
            merchandPassword: merchandPassword,
            provider_short_tag: provider_short_tag,
            actionAfterProccess: actionAfterProccess,
            context: context,
            sandbox: sandbox,
            X_API_KEY: X_API_KEY);
      } else {
        print(" Else response /makePayment : ${json.decode(response.body)}");
        jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          payUnitStream.paymentSink.addError("Error");
          print(" Else response /makePayment : ${json.decode(response)}");
          closeDialog(context);
          constant.makeToast(jsonResponse['error'], context, Colors.red);

        }
      }
    } catch (e) {
      print("Make payment error : $e");
      closeDialog(context);
      constant.makeToast("Something went wrong , please try again or later",
          context, Colors.red);
    } finally {
      // closeDialog(context);
    }
  }

  Future<void> initPusher(
      channelName, actionAfterProccess, BuildContext context) async {
    print("Transaction id pusher : $channelName");
    // print("Transaction actionAfterProcess : $actionAfterProcess");

    try {
      await Pusher.init('8e6ec079f9d817bd73eb', PusherOptions(cluster: 'ap4'));
    } catch (e) {
      print(e.message);
    }
    //connect to pusher
    Pusher.connect(
        onConnectionStateChange: (ConnectionStateChange connectionState) async {
          print("Pusher connection state : ${connectionState.currentState}");
        }, onError: (ConnectionError e) {
      print("Error: ${e.message}");
    });

    //connect to channel
    channel = await Pusher.subscribe(channelName);
    //get data
    channel.bind('payment-event', (last) {
      // print("this is pusher : ${last.data}");

      if (jsonDecode(last.data)['transaction_status'] == "SUCCESS") {
        constant.makeToast(
            "Your transaction : ${jsonDecode(last.data)['transaction_id']} have the status: ${jsonDecode(last.data)['transaction_status']}",
            context,
            jsonDecode(last.data)['transaction_status'] == "SUCCESS"
                ? Colors.green
                : Colors.red);
        actionAfterProccess(jsonDecode(last.data)['transaction_id'],
            jsonDecode(last.data)['transaction_status']);
        closeDialog(context);
      } else {
        constant.makeToast(
            "Your transaction failed , please try again or later",
            context,
            Colors.red);
        payUnitStream.paymentSink.addError("error");
      }
    });
  }

  void unbindEvent() {
    channel.unbind('payment-event');
  }

  void unSubscribePusher(String channelName) {
    Pusher.unsubscribe(channelName);
  }

  //Able to check the status of the payment of payment to Ecobank
  // checkEcobankStatusPayment() {}

  // String getEncode() {
  //   String credentials = "myeasylight-payments:easylight-payments@2020*";
  //   Codec<String, String> stringToBase64 = utf8.fuse(base64);
  //   String encoded = stringToBase64.encode(credentials);
  //   return encoded;
  // }
  // http_auth.DigestAuthClient
  getDigestAuth(String username, String password) {
    var digest = http_auth.DigestAuthClient(username, password);
    return digest;
  }

  getGlobalHeader(String X_API_KEY) {
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': X_API_KEY,
    };
  }

  progressHub(msg, context) {
    NativeProgressHud.showWaitingWithText(msg);
  }

  closeDialog(context) {
    NativeProgressHud.hideWaiting();
  }

  Future<String> createCheckout(
      {@required amount,
        @required productName,
        @required qty,
        @required currency,
        @required secretKey,
        @required context,
        @required transaction_id}) async {
    final auth = 'Basic ' + base64Encode(utf8.encode('$secretKey:'));
    print(" transaction_id in checkout: $transaction_id");
    final body = {
      'payment_method_types': ['card'],
      'line_items': [
        {
          'quantity': qty,
          'amount': amount,
          'currency': currency,
          'name': productName,
        }
      ],
      'mode': 'payment',
      'success_url': 'https://success.com',
      'cancel_url': 'https://cancel.com',
    };

    try {
      final result = await Dio().post(
        "https://api.stripe.com/v1/checkout/sessions",
        data: body,
        options: Options(
          headers: {HttpHeaders.authorizationHeader: auth},
          contentType: "application/x-www-form-urlencoded",
        ),
      );
      return result.data['id'];
    } on DioError catch (e, s) {
      print("SessionId Error : ${e.response}");
      closeDialog(context);
      constant.makeToast("Something went wrong , please try again or later",
          context, Colors.red);

      throw e;
    }
  }

  Future<String> stripeCallBackTransactionIdAndStatus(
      {@required transactionId,
        @required transactionStatus,
        @required context,
        @required merchandUserName,
        @required merchandPassword,
        @required sandbox,
        @required X_API_KEY}) async {
    var data = jsonEncode({
      "transaction_id": transactionId,
      "transaction_status": transactionStatus
    });
    print("This is my data : $data");
    progressHub("Please wait", context);
    var response = await getDigestAuth(merchandUserName, merchandPassword).post(
        "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/stripeCallbackMobile",
        body: data,
        headers: getGlobalHeader(X_API_KEY));
    var jsonResponse = json.decode(response.body);
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        // print(
        //     "200 response /stripeCallBackTransactionIdAndStatus : $jsonResponse");
        if (transactionStatus == "SUCCESS") {
          makeToast("Paypal payment success", context, Colors.green);
        } else {
          makeToast("Paypal payment Failed", context, Colors.red);
        }
      } else {
        print(" Else response /stripeCallBackTransactionIdAndStatus : $jsonResponse");
      }
    } catch (e) {
      print("StripeCallBack error => $e");
      constant.makeToast("Something went wrong , please try again or later",
          context, Colors.red);
    } finally {
      closeDialog(context);
    }
  }
}
