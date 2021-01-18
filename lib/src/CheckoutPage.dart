import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ApiService.dart';
import 'Constant/Constant.dart';


class CheckoutPage extends StatefulWidget {
  final String sessionId;
  final String publishKey;
  final String transactionId;
  // final context;
  final String merchandUserName;
  final String merchandPassword;
  final String sandbox;
  final String X_API_KEY;

  const CheckoutPage({Key key,
    @required this.sessionId,
    @required this.publishKey,
    @required this.transactionId,
    // @required this.context,
    @required this.merchandUserName,
    @required this.merchandPassword,
    @required this.sandbox,
    @required this.X_API_KEY})
      : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
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
              print("Hello stripe ");
              _redirectToStripe(widget.sessionId);
            }
          },
          navigationDelegate: (NavigationRequest request) {
            print("The request : $request");
            if (request.url.startsWith('https://success.com')) {
              Navigator.of(context).pop();
              api.stripeCallBackTransactionIdAndStatus(
                  transactionId: widget.transactionId,
                  transactionStatus: "SUCCESS",
                  context: context,
                  merchandUserName: widget.merchandUserName,
                  merchandPassword: widget.merchandPassword,
                  sandbox: widget.sandbox,
                  X_API_KEY: widget.X_API_KEY);
              makeToast("Stripe payment success", context, Colors.green);
            } else if (request.url.startsWith('https://cancel.com')) {
              makeToast("Stripe payment failed , please try again/later",
                  context, Colors.red);
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

  String get initialUrl => 'https://hostedpages.sevengps.net/#/mobileStripe?publishKey=${widget.publishKey}&sessionID=${widget.sessionId}';

  Future<void> _redirectToStripe(String sessionId) async {
    print("This is sessionID : $sessionId");
    final redirectToCheckoutJs = '''
var stripe = Stripe(\'${widget.publishKey}\');
stripe.redirectToCheckout({
  sessionId: '$sessionId'
}).then(function (result) {
  result.error.message = 'Error'
  console.log("This is js error ", result.error.message)
});
''';

    try {
      await _webViewController.evaluateJavascript(redirectToCheckoutJs);
    } on PlatformException catch (e) {
      if (!e.details.contains(
          'JavaScript execution returned a result of an unsupported type')) {
        makeToast("Something went wrong , please try again or later", context,
            Colors.red);
        rethrow;
      }
    }
  }
}
