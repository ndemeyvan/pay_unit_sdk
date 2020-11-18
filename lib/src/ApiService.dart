import 'dart:async';
import 'dart:convert';
import 'blocs/PayUnitStream.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:native_progress_hud/native_progress_hud.dart';
import './Constant/Constant.dart'as constant;

class ApiService {
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
  }) async {
    try {
      var data = jsonEncode({
        "description": description,
        "transaction_id": transaction_id,
        "total_amount": transactionAmount,
        "return_url": "https://eneocameroon.cm/index.php/en/"
      });
      print("this is data send to server : $data");
      var jsonResponse;
      var response = await getDigestAuth(merchandUserName, merchandPassword)
          .post("${constant.baseUrl}/gateway/initialize",
          body: data, headers: getGlobalHeader(X_API_KEY));
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
          ));
        }
      } else {
        print("Else bloc in initiatePayment Function  : ${response.headers}");

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
  }) async {
    try {
      print(
          "This is the data of getAllProvider \ntransactionId :$transactionId \ntransactionAmount $transactionAmount  \ntransactionCallBackUrl $transactionCallBackUrl \nmerchandUserName $merchandUserName \merchandPassword $merchandPassword");

      var jsonResponse;
      var response = await getDigestAuth(merchandUserName, merchandPassword).get(
          "${constant.baseUrl}/gateway/gateways?t_id=$transactionId&t_sum=$transactionAmount&t_url=$transactionCallBackUrl",
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
  }) async {
    try {
      // callback;
      const time = const Duration(seconds: 4);
      Timer _timer;
      _timer= new Timer.periodic(time, (Timer timer) async {
        var jsonResponse;
        var response = await getDigestAuth(merchandUserName, merchandPassword).get(
            "${constant.baseUrl}/gateway/paymentstatus/$provider_short_tag/$transactionId?payment_ref=${paymentRef}&pay_token=${payToken}",
            headers: getGlobalHeader(X_API_KEY));
        jsonResponse = json.decode(response.body);
        if (response.statusCode == 200) {
          if (jsonResponse != null) {
            print(" 200 response /providers : $jsonResponse");
            if(jsonResponse['status'] == "PENDING"){
              // the payment is pending , wait for another timer period
            }else {
              _timer.cancel();
              constant.succesPaymentDialog("Payment success", context, "Thank using Payunit payment", actionAfterProccess);
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
  /// [transactionAmount] : the amount you want to pay
  /// [transactionCallBackUrl] : your callBack url
  /// [provider_short_tag] : the tag of the provider
  /// [phoneNumber] : the phone number of the client
  /// [userName] : the user name of the client
  makePayment({
    @required  context,
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
    try {

      print("this is sending data : $data");
      var jsonResponse;
      if (provider_short_tag == 'mtnmomo' || provider_short_tag == 'orange') {
        response = await getDigestAuth(merchandUserName, merchandPassword).post(
            "${constant.baseUrl}/gateway/makepayment",
            body: data,
            headers: getGlobalHeader(X_API_KEY));
      } else if (provider_short_tag == 'eu') {
        response = await http.post(
            "${constant.baseUrl}/payments/gateway/makepayment",
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
      print(" Catch error /makePayment : ${e}");
      payUnitStream.paymentSink.addError("Error");
      closeDialog(context);
    } finally {
      closeDialog(context);
    }
  }

  //Able to check the status of the payment of payment to Ecobank
  // checkEcobankStatusPayment() {}

  String getEncode() {
    String credentials = "myeasylight-payments:easylight-payments@2020*";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    return encoded;
  }

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
