import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ApiService.dart';
import 'Constant/Constant.dart';


class CheckoutPaypalPage extends StatefulWidget {
  final String orderId;
  final String transactionId;
  final amount;
  final String merchandUserName;
  final String merchandPassword;
  final String sandbox;
  final String X_API_KEY;

  const CheckoutPaypalPage({Key key,
    @required this.orderId,
    @required this.transactionId,
    @required this.amount,
    @required this.merchandUserName,
    @required this.merchandPassword,
    @required this.sandbox,
    @required this.X_API_KEY})
      : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPaypalPage> {
  WebViewController _webViewController;
  ApiService api = new ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: WebView(
          initialUrl: initialUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (webViewController) =>
          _webViewController = webViewController,
          onPageFinished: (String url) {
            if (url == initialUrl) {
              print("onPageFished passed");
            }
          },
          navigationDelegate: (NavigationRequest request) {
            print("The request : $request");
            if (request.url.startsWith('https://success.com')) {
              api.stripeCallBackTransactionIdAndStatus(
                  transactionId: widget.transactionId,
                  transactionStatus: "SUCCESS",
                  context: context,
                  merchandUserName: widget.merchandUserName,
                  merchandPassword: widget.merchandPassword,
                  sandbox: widget.sandbox,
                  X_API_KEY: widget.X_API_KEY);
              Navigator.of(context).pop();
            } else if (request.url.startsWith('https://cancel.com')) {
              api.stripeCallBackTransactionIdAndStatus(
                  transactionId: widget.transactionId,
                  transactionStatus: "FAILED",
                  context: context,
                  merchandUserName: widget.merchandUserName,
                  merchandPassword: widget.merchandPassword,
                  sandbox: widget.sandbox,
                  X_API_KEY: widget.X_API_KEY);
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }

  String get initialUrl => 'https://hostedpages.sevengps.net/#/mobilePayPal?amount=${widget.amount}&transactionId=${widget.transactionId}&order_id=${widget.orderId}';

}
