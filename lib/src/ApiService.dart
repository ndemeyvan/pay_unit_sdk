import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pusher_websocket_flutter/pusher.dart';

import 'blocs/PayUnitStream.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:native_progress_hud/native_progress_hud.dart';
import './Constant/Constant.dart'as constant;

class ApiService {
  Channel channel;
  //  var baseUrl = "https://gateway-test.eneoapps.com:5000";//gateway test
  /// [context] : the actual context of the app
  /// [X_API_KEY] : the x-api-key
  /// [transactionAmount] : the amount you want to pay
  /// [transactionCallBackUrl] : your callBack url
  initiatePayment({
    @required context,
    @required String X_API_KEY,
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

      print(" is sandbox ? /initiatePayment: $sandbox");
      var data = jsonEncode({
        "description": description,
        "transaction_id": transaction_id,
        "total_amount": transactionAmount,
        "return_url": "https://eneocameroon.cm/index.php/en/"
      });
      print("this is data send to server : $data");
      var jsonResponse;
      print(
          "this is base Url : ${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}");

      var response = await getDigestAuth(merchandUserName, merchandPassword).post(
          "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/initialize",
          body: data,
          headers: getGlobalHeader(X_API_KEY));
      jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonResponse != null) {
          print(" 201 ou 200 response /initiate : ${response.body}");
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
        print("Else bloc in initiatePayment Function  : $jsonResponse");
        closeDialog(context);
      }
    } catch (e) {
      print("InitiatePayment catchError : $e");
      closeDialog(context);
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
      print(
          "This is the data of getAllProvider \ntransactionId :$transactionId \ntransactionAmount $transactionAmount  \ntransactionCallBackUrl $transactionCallBackUrl \nmerchandUserName $merchandUserName \merchandPassword $merchandPassword");
      print(" is sandbox ? /getAllProviders : $sandbox");

      var jsonResponse;
      var response = await getDigestAuth(merchandUserName, merchandPassword).get(
          "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/gateways?t_id=$transactionId&t_sum=$transactionAmount&t_url=$transactionCallBackUrl",
          headers: getGlobalHeader(X_API_KEY));
      jsonResponse = json.decode(response.body);
      print("This is the result of getAllProvider : ${response.body}");
      if (response.statusCode == 200) {
        if (jsonResponse != null) {
          print(" 200 response /providers : $jsonResponse");
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
      // callback;
      const time = const Duration(seconds: 4);
      Timer _timer;
      _timer = new Timer.periodic(time, (Timer timer) async {
        var jsonResponse;
        var response = await getDigestAuth(merchandUserName, merchandPassword).get(
            "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl}/gateway/paymentstatus/$provider_short_tag/$transactionId?payment_ref=${paymentRef}&pay_token=${payToken}",
            headers: getGlobalHeader(X_API_KEY));
        jsonResponse = json.decode(response.body);
        if (response.statusCode == 200) {
          if (jsonResponse != null) {
            print(" 200 response /getPaymentStatus : $jsonResponse");
            if (jsonResponse['status'] == "PENDING") {
              // the payment is pending , wait for another timer period
            } else if (jsonResponse['status'] == "SUCCESSFUL") {
              _timer.cancel();
              // constant.succesPaymentDialog("Payment success", context,
              //     "Thank using Payunit payment", actionAfterProccess);
              // unSubscribePusher(transactionId);
              // unbindEvent();
            } else {
              _timer.cancel();
              // payUnitStream.paymentSink.addError("error");
            }
          }
        } else {
          if (jsonResponse != null) {
            print(" Else response /providers : $jsonResponse");
            closeDialog(context);
            _timer.cancel();
            payUnitStream.paymentSink.addError("error");
          }
        }
      });
    } catch (e) {
      print(" catch error /providers : ${e}");
      closeDialog(context);
    } finally {
      closeDialog(context);
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
  }) async {
    var response;
    var data = jsonEncode({
      'gateway': provider_short_tag,
      'amount': transactionAmount,
      'transaction_id': transaction_id,
      'return_url': transactionCallBackUrl,
      'phone_number': phoneNumber,
      'description': "Pay unit flutter sdk",
      "name": provider_short_tag
    });
    print(" is sandbox ? /makePayment: $sandbox");
    constant.makeToast(
        "Your transaction has been initiated", context, Colors.blue);
    Navigator.of(context).pop();
    try {
      print("this is sending data : $data");
      var jsonResponse;
      if (provider_short_tag == 'mtnmomo' || provider_short_tag == 'orange') {
        print(
            "this is route : ${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl + '/payments'}/gateway/makepayment");
        response = await getDigestAuth(merchandUserName, merchandPassword).post(
            "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl + '/payments'}/gateway/makepayment",
            body: data,
            headers: getGlobalHeader(X_API_KEY));
      } else if (provider_short_tag == 'eu') {
        response = await http.post(
            "${sandbox == 'sandbox' ? constant.baseUrlSandBox : constant.baseUrl + '/payments'}/gateway/makepayment",
            // "${sandbox =='sandbox' ? constant.baseUrlSandBox : constant.baseUrl }/payments/gateway/makepayment",
            body: data,
            headers: getGlobalHeader(X_API_KEY));
      }

      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body)["data"];
        if (jsonResponse != null) {
          print(" 200 response /makePayment : $jsonResponse");
          // json.decode(response.body)['data'];
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
        }
        // actionAfterProccess();
      } else {
        jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          payUnitStream.paymentSink.addError("Error");
          print(" Else response /makePayment : ${json.decode(response.body)}");
          closeDialog(context);
        }
      }
    } catch (e) {
      print("  error /makePayment : ${e}");
      closeDialog(context);
    } finally {
      closeDialog(context);
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
          print("Connection state : ${connectionState.currentState}");
        }, onError: (ConnectionError e) {
      print("Error: ${e.message}");
    });

    //connect to channel
    channel = await Pusher.subscribe(channelName);
    //get data
    channel.bind('payment-event', (last) {
      print("this is pusher : ${last.data}");

      if (jsonDecode(last.data)['transaction_status'] == "SUCCESS") {
        constant.makeToast(
            "Your transaction : ${jsonDecode(last.data)['transaction_id']} have the status: ${jsonDecode(last.data)['transaction_status']}",
            context,
            jsonDecode(last.data)['transaction_status'] == "SUCCESS"
                ? Colors.green
                : Colors.red);
        actionAfterProccess(jsonDecode(last.data)['transaction_id'],
            jsonDecode(last.data)['transaction_status']);
      } else {
        constant.makeToast("Your transaction failed", context, Colors.red);
        payUnitStream.paymentSink.addError("error");
      }
    });
  }

  Future<void> blabla(last) {}

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
}
