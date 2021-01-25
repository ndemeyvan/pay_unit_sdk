import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pay_unit_sdk/src/CheckoutPage.dart';
import 'package:pay_unit_sdk/src/CheckoutPaypalPage.dart';
import '../pay_unit_sdk.dart';
import 'ApiService.dart';
import './blocs/PayUnitStream.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:native_progress_hud/native_progress_hud.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import './Constant/Constant.dart' as constant;


class PayUnitButton extends StatefulWidget {
  final Function(String transactionId, String transactionStatus)
  actionAfterProccess;
  final String productName;
  final IconData icon;
  final double width;
  final bool isFixedHeight;
  final Color color;
  final String transactionAmount;
  final String transactionCallBackUrl;
  final String apiUser;
  final String apiPassword;
  final String apiKey;
  final String sandbox;
  final String notiFyUrl;

  const PayUnitButton({
    @required this.actionAfterProccess,
    @required this.productName,
    @required this.color,
    @required this.transactionAmount,
    @required this.transactionCallBackUrl,
    @required this.apiUser,
    @required this.apiPassword,
    @required this.apiKey,
    @required this.sandbox,
    @required this.notiFyUrl,
    this.width = double.infinity,
    this.isFixedHeight = true,
    this.icon,
  });

  @override
  _PayUnitButtonState createState() => _PayUnitButtonState();
}

class _PayUnitButtonState extends State<PayUnitButton> with AnimationMixin {
  Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    final curveAnimation = CurvedAnimation(
        parent: controller, curve: Curves.easeIn, reverseCurve: Curves.easeIn);
    _scale = Tween<double>(begin: 1, end: 0.9).animate(curveAnimation);
  }

  void _onTapDown(TapDownDetails details) {
    controller.play(duration: Duration(milliseconds: 150));
  }

  void _onTapUp(TapUpDetails details) {
    if (controller.isAnimating) {
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed)
          controller.playReverse(duration: Duration(milliseconds: 100));
      });
    } else
      controller.playReverse(duration: Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMaterialModalBottomSheet(
          context: context,
          builder: (context, scrollController) => PayDialog(
            X_API_KEY: widget.apiKey,
            productName: widget.productName,
            transactionCallBackUrl: widget.transactionCallBackUrl,
            transactionAmount: widget.transactionAmount,
            actionAfterProccess: widget.actionAfterProccess,
            merchandPassword: widget.apiPassword,
            merchandUserName: widget.apiUser,
            sandbox: widget.sandbox,
          ),
        );
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        controller.playReverse(
          duration: Duration(milliseconds: 100),
        );
      },
      child: Transform.scale(
        scale: _scale.value,
        child: _animatedButtonUI,
      ),
    );
  }

  Widget get _animatedButtonUI => Container(
    height: widget.isFixedHeight ? 50.0 : null,
    width: widget.width,
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(100)),
        color: widget.color ?? Theme.of(context).primaryColor),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // : SizedBox(),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            'Pay with PayUnit',
            // maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
        ),
        // SizedBox(
        //   width: 10,
        // ),
        // Padding(
        //   padding: const EdgeInsets.only(left: 4.0),
        //   child: Icon(
        //     FontAwesomeIcons.moneyBill,
        //     color: Colors.white,
        //   ),
        // ),
      ],
    ),
  );
}

class PayDialog extends StatefulWidget {
  final Function actionAfterProccess;
  final String X_API_KEY;
  final transactionAmount;
  final productName;
  final transactionCallBackUrl;
  final String merchandUserName;
  final String merchandPassword;
  final String sandbox;

  const PayDialog({
    @required this.X_API_KEY,
    @required this.productName,
    @required this.transactionAmount,
    @required this.transactionCallBackUrl,
    @required this.actionAfterProccess,
    @required this.merchandUserName,
    @required this.merchandPassword,
    @required this.sandbox,
  });

  @override
  _PayDialogState createState() => _PayDialogState();
}

class _PayDialogState extends State<PayDialog> with AnimationMixin {
  Animation<double> _scale;

  //Make A get request to get All the Actual Providers
  ApiService api = new ApiService();
  String transaction_id = constant.getRandomId();

  @override
  void initState() {
    super.initState();
    final curveAnimation = CurvedAnimation(
        parent: controller, curve: Curves.easeIn, reverseCurve: Curves.easeIn);
    _scale = Tween<double>(begin: 1, end: 0.9).animate(curveAnimation);
    api.initiatePayment(
        transactionAmount: widget.transactionAmount,
        transactionCallBackUrl: widget.transactionCallBackUrl,
        X_API_KEY: widget.X_API_KEY,
        productName: widget.productName,
        context: context,
        transaction_id: transaction_id,
        description: "Pay unit mobile payment",
        merchandPassword: widget.merchandPassword,
        sandbox: widget.sandbox,
        merchandUserName: widget.merchandUserName,
        actionAfterProccess: widget.actionAfterProccess);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: payUnitStream.settListProviderStream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return constant.errorConnexion();
                      } else if (snapshot.connectionState ==
                          ConnectionState.none) {
                        return Text("Turn on Your internet Connexion");
                      } else if (snapshot.data == null) {
                        return Container(
                          child: Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      } else {
                        if (snapshot.data.length <= 0) {
                          return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      height:
                                      MediaQuery.of(context).size.height * 0.15,
                                      child: Text(
                                        "No Providers",
                                        style: TextStyle(color: Colors.black),
                                      )),
                                  SizedBox(
                                    height:
                                    MediaQuery.of(context).size.height * 0.05,
                                  ),
                                ],
                              ));
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.length,
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                          onTap: () async {
                                            String provider_short_tag =
                                            snapshot.data[index]
                                            ['provider_short_tag'];
                                            print(
                                                "provider_id : $provider_short_tag");
                                            if (provider_short_tag ==
                                                "mtnmomo" ||
                                                provider_short_tag ==
                                                    "orange") {
                                              Navigator.pop(context);
                                              showMaterialModalBottomSheet(
                                                context: context,
                                                builder: (context,
                                                    scrollController) =>
                                                    PayDialogWithMomo(
                                                      X_API_KEY: widget.X_API_KEY,
                                                      productName: widget.productName,
                                                      transactionCallBackUrl: widget
                                                          .transactionCallBackUrl,
                                                      transactionAmount:
                                                      widget.transactionAmount,
                                                      actionAfterProccess: widget
                                                          .actionAfterProccess,
                                                      provider_short_tag: snapshot
                                                          .data[index]
                                                      ['provider_short_tag'],
                                                      merchandUserName:
                                                      widget.merchandUserName,
                                                      merchandPassword:
                                                      widget.merchandPassword,
                                                      transaction_id:
                                                      transaction_id,
                                                      sandbox: widget.sandbox,
                                                    ),
                                              );
                                            } else if (provider_short_tag ==
                                                "eu") {
                                              // showMaterialModalBottomSheet(
                                              //   context: context,
                                              //   builder: (context,
                                              //           scrollController) =>
                                              //       PayDialogWithExpressUnion(
                                              //     X_API_KEY: widget.X_API_KEY,
                                              //         productName: widget.productName,
                                              //     transactionCallBackUrl: widget
                                              //         .transactionCallBackUrl,
                                              //     transactionAmount:
                                              //         widget.transactionAmount,
                                              //     actionAfterProccess: widget
                                              //         .actionAfterProccess,
                                              //     provider_short_tag: snapshot
                                              //             .data[index]
                                              //         ['provider_short_tag'],
                                              //     merchandUserName:
                                              //         widget.merchandUserName,
                                              //     merchandPassword:
                                              //         widget.merchandPassword,
                                              //     transaction_id:
                                              //         transaction_id,
                                              //     sandbox: widget.sandbox,
                                              //   ),
                                              // );
                                              makeToast(
                                                  "Not yet available",
                                                  context,
                                                  Colors.black);
                                            } else if (provider_short_tag ==
                                                'stripe') {
                                              // Navigator.of(context).pop();
                                              var payUnitResult =
                                              await api.makePayment(
                                                  X_API_KEY:
                                                  widget.X_API_KEY,
                                                  transactionAmount: widget
                                                      .transactionAmount,
                                                  transactionCallBackUrl: widget
                                                      .transactionCallBackUrl,
                                                  phoneNumber: "6562090008",
                                                  provider_short_tag:
                                                  provider_short_tag,
                                                  userName: "",
                                                  merchandPassword: widget
                                                      .merchandPassword,
                                                  merchandUserName: widget
                                                      .merchandUserName,
                                                  sandbox: widget.sandbox,
                                                  transaction_id:
                                                  transaction_id,
                                                  context: context,
                                                  currency: "USD",
                                                  actionAfterProccess: widget
                                                      .actionAfterProccess);
                                              // print(" Result on payButton : $payUnitResult");
                                              final sessionId =
                                              await api.createCheckout(
                                                  amount: widget
                                                      .transactionAmount,
                                                  productName:
                                                  widget.productName,
                                                  qty: 1,
                                                  currency: "USD",
                                                  secretKey: payUnitResult[
                                                  "secret_key"],
                                                  context: context,
                                                  transaction_id:
                                                  transaction_id);
                                              api.closeDialog(context);
                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (_) => CheckoutPage(
                                                      sessionId: sessionId,
                                                      publishKey: payUnitResult[
                                                      "publishable_key"],
                                                      transactionId:
                                                      transaction_id,
                                                      // context: context,
                                                      merchandUserName: widget
                                                          .merchandUserName,
                                                      merchandPassword: widget
                                                          .merchandPassword,
                                                      sandbox: widget.sandbox,
                                                      X_API_KEY:
                                                      widget.X_API_KEY)));
                                              makeToast(
                                                  "Please wait the loading of Stripe ...",
                                                  context,
                                                  Colors.black);

                                            }else if(provider_short_tag ==
                                                'paypal'){
                                              var payUnitResult =
                                              await api.makePayment(
                                                  X_API_KEY:
                                                  widget.X_API_KEY,
                                                  currency: "USD",
                                                  transactionAmount: widget
                                                      .transactionAmount,
                                                  transactionCallBackUrl: widget
                                                      .transactionCallBackUrl,
                                                  phoneNumber: null,
                                                  provider_short_tag:
                                                  provider_short_tag,
                                                  userName: "",
                                                  merchandPassword: widget
                                                      .merchandPassword,
                                                  merchandUserName: widget
                                                      .merchandUserName,
                                                  sandbox: widget.sandbox,
                                                  transaction_id:
                                                  transaction_id,
                                                  context: context,
                                                  actionAfterProccess: widget
                                                      .actionAfterProccess);

                                              Navigator.of(context).pop();
                                              Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (_) => CheckoutPaypalPage(
                                                      orderId: payUnitResult[
                                                      "order_id"],
                                                      transactionId:
                                                      transaction_id,
                                                      // context: context,
                                                      merchandUserName: widget
                                                          .merchandUserName,
                                                      merchandPassword: widget
                                                          .merchandPassword,
                                                      amount: widget
                                                          .transactionAmount,
                                                      sandbox: widget.sandbox,
                                                      X_API_KEY:
                                                      widget.X_API_KEY)));
                                              makeToast(
                                                  "Please wait the loading of Paypal ...",
                                                  context,
                                                  Colors.black);
                                            }else  if (provider_short_tag ==
                                                "yup" ) {
                                              makeToast(
                                                  "Not yet available",
                                                  context,
                                                  Colors.black);
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                  decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadiusDirectional
                                                              .circular(
                                                              20))),
                                                  margin: EdgeInsets.zero,
                                                  padding: EdgeInsets.only(
                                                      left: 5, right: 5),
                                                  child: Card(
                                                    shape:
                                                    BeveledRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                    ),
                                                    child: Image(
                                                      image: NetworkImage(
                                                        snapshot.data[index]
                                                        ['provider_logo'],
                                                      ),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  )),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              AutoSizeText(
                                                snapshot.data[index]
                                                ['provider_name'],
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                              // Text(
                                              //   snapshot.data[index]
                                              //       ['provider_name'],
                                              //   textAlign: TextAlign.center,
                                              //   style: TextStyle(
                                              //       color: Colors.black,),
                                              // )
                                            ],
                                          ));
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                  ),
                                  Text(
                                    "Choice Your Payment method.",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                    })),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
          ],
        ));
  }
}

class PayDialogWithMomo extends StatefulWidget {
  final String X_API_KEY;
  final String transactionAmount;
  final Function actionAfterProccess;
  final String provider_short_tag;
  final String phoneNumber;
  final String transaction_id;
  final String transactionCallBackUrl;
  final String merchandUserName;
  final String merchandPassword;
  final String sandbox;
  final String productName;

  const PayDialogWithMomo({
    this.X_API_KEY,
    this.productName,
    this.transactionAmount,
    this.actionAfterProccess,
    this.provider_short_tag,
    this.transactionCallBackUrl,
    this.phoneNumber,
    this.transaction_id,
    this.merchandUserName,
    this.merchandPassword,
    this.sandbox,
  });

  @override
  _PayDialogWithTelcoState createState() => _PayDialogWithTelcoState();
}

class _PayDialogWithTelcoState extends State<PayDialogWithMomo>
    with AnimationMixin {
  final phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

//////////////////Methods

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: StreamBuilder(
              initialData: false,
              stream: payUnitStream.paymentStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: constant.paymentComponent(
                        true,
                        context,
                        widget.transactionAmount,
                        _formKey,
                        _autoValidate,
                        phoneController,
                        widget.X_API_KEY,
                        widget.transaction_id,
                        widget.transactionCallBackUrl,
                        widget.provider_short_tag,
                        widget.merchandPassword,
                        widget.merchandUserName,
                        widget.actionAfterProccess, () {
                      setState(() {
                        _autoValidate = true;
                      });
                    }, widget.sandbox),
                  );
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Text("Turn on Your internet Connexion");
                } else if (snapshot.data == true) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        CupertinoActivityIndicator(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        Text(
                          "Your payment is in progress , please wait ...",
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: constant.paymentComponent(
                        false,
                        context,
                        widget.transactionAmount,
                        _formKey,
                        _autoValidate,
                        phoneController,
                        widget.X_API_KEY,
                        widget.transaction_id,
                        widget.transactionCallBackUrl,
                        widget.provider_short_tag,
                        widget.merchandPassword,
                        widget.merchandUserName,
                        widget.actionAfterProccess, () {
                      setState(() {
                        _autoValidate = true;
                      });
                    }, widget.sandbox),
                  );
                }
              })),
    );
  }

  ////////////////////utility class
  progressHub(msg, context) {
    NativeProgressHud.showWaitingWithText(msg);
  }

  closeDialog(context) {
    NativeProgressHud.hideWaiting();
  }

  NumberFormat getOcy() {
    final oCcy = new NumberFormat("#,##0", "en_us");
    return oCcy;
  }
}

//////////////
class PayDialogWithExpressUnion extends StatefulWidget {
  final String X_API_KEY;
  final String transactionAmount;
  final Function actionAfterProccess;
  final String provider_short_tag;
  final String phoneNumber;
  final String transactionCallBackUrl;
  final String merchandUserName;
  final String merchandPassword;
  final String sandbox;
  final String transaction_id;
  final String productName;

  const PayDialogWithExpressUnion({
    this.X_API_KEY,
    this.productName,
    this.transactionAmount,
    this.actionAfterProccess,
    this.provider_short_tag,
    this.transactionCallBackUrl,
    this.phoneNumber,
    this.merchandUserName,
    this.merchandPassword,
    this.sandbox,
    this.transaction_id,
  });

  @override
  _PayDialogWithExpressUnionState createState() =>
      _PayDialogWithExpressUnionState();
}

class _PayDialogWithExpressUnionState extends State<PayDialogWithExpressUnion>
    with AnimationMixin {
  final phoneController = TextEditingController();
  final userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Text(
                "${getOcy().format((int.parse(widget.transactionAmount)))} XAF",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: MediaQuery.of(context).size.width * 0.080,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
              ),
              TextField(
                keyboardType: TextInputType.text,
                controller: userNameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.020),
                  hintText: "Enter your User name",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.032,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.userCircle,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: phoneController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.020),
                  hintText: "Enter your phone number",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.032,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.phoneAlt,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              AnimButton(
                color: Colors.orange,
                pressEvent: () {
                  String phoneNumber = phoneController.text;
                  String userName = userNameController.text;
                  if (phoneNumber.isEmpty || userName.isEmpty) {
                    ///show diaolog alert the field is empty
                    print('Phone number is empty');
                  } else {
                    AwesomeDialog(
                        dismissOnBackKeyPress: false,
                        dismissOnTouchOutside: false,
                        context: context,
                        dialogType: DialogType.INFO,
                        animType: AnimType.BOTTOMSLIDE,
                        title: "Confirm",
                        desc: 'Do you want to confirm this payment',
                        btnOkColor: Colors.green,
                        btnOkText: "Confirm",
                        btnOkIcon: Icons.check,
                        btnOkOnPress: () {
                          ApiService api = new ApiService();
                          api.makePayment(
                              X_API_KEY: widget.X_API_KEY,
                              transactionAmount: widget.transactionAmount,
                              transactionCallBackUrl:
                              widget.transactionCallBackUrl,
                              phoneNumber: phoneController.text,
                              provider_short_tag: widget.provider_short_tag,
                              userName: userName,
                              merchandPassword: widget.merchandPassword,
                              merchandUserName: widget.merchandUserName,
                              sandbox: widget.sandbox,
                              transaction_id: widget.transaction_id,
                              context: context,
                              actionAfterProccess: widget.actionAfterProccess);
                        },
                        btnCancelOnPress: () {},
                        btnCancelColor: Colors.red,
                        btnCancelIcon: Icons.cancel,
                        btnCancelText: 'Cancel')
                      ..show();
                  }
                },
                text: 'Make Payment',
              )
            ],
          ),
        ),
      ),
    );
  }
}

//////////////
// class PayDialogWithEcobank extends StatefulWidget {
//   final String X_API_KEY;
//   final String transactionAmount;
//   final Function actionAfterProccess;
//   final String provider_short_tag;
//   final String phoneNumber;
//   final String transactionCallBackUrl;
//   final String sandbox;
//
//   const PayDialogWithEcobank(
//       {this.X_API_KEY,
//       this.transactionAmount,
//       this.actionAfterProccess,
//       this.provider_short_tag,
//       this.transactionCallBackUrl,
//       this.sandbox,
//       this.phoneNumber});
//
//   @override
//   _PayDialogWithEcobankState createState() => _PayDialogWithEcobankState();
// }
//
// class _PayDialogWithEcobankState extends State<PayDialogWithEcobank>
//     with AnimationMixin {
//   final Completer<WebViewController> _controller =
//       Completer<WebViewController>();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   final Set<Factory> gestureRecognizers = [
//     Factory(() => EagerGestureRecognizer()),
//   ].toSet();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height / 1.5,
//       child: WebView(
//           initialUrl: 'https://ecobank.com',
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (WebViewController webViewController) {
//             _controller.complete(webViewController);
//           },
//           gestureNavigationEnabled: true,
//           gestureRecognizers: gestureRecognizers),
//     );
//   }
// }

////////////// Utils
progressHub(msg, context) {
  NativeProgressHud.showWaitingWithText(msg);
}

closeDialog(context) {
  NativeProgressHud.hideWaiting();
}

NumberFormat getOcy() {
  final oCcy = new NumberFormat("#,##0", "en_us");
  return oCcy;
}

class AnimButton extends StatefulWidget {
  final Function pressEvent;
  final String text;
  final IconData icon;
  final double width;
  final bool isFixedHeight;
  final Color color;

  const AnimButton(
      {@required this.pressEvent,
        this.text,
        this.icon,
        this.color,
        this.isFixedHeight = true,
        this.width = double.infinity});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimButton> with AnimationMixin {
  Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    final curveAnimation = CurvedAnimation(
        parent: controller, curve: Curves.easeIn, reverseCurve: Curves.easeIn);
    _scale = Tween<double>(begin: 1, end: 0.9).animate(curveAnimation);
  }

  void _onTapDown(TapDownDetails details) {
    controller.play(duration: Duration(milliseconds: 150));
  }

  void _onTapUp(TapUpDetails details) {
    if (controller.isAnimating) {
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed)
          controller.playReverse(duration: Duration(milliseconds: 100));
      });
    } else
      controller.playReverse(duration: Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.pressEvent();
        //  _controller.forward();
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        controller.playReverse(
          duration: Duration(milliseconds: 100),
        );
      },
      child: Transform.scale(
        scale: _scale.value,
        child: _animatedButtonUI,
      ),
    );
  }

  Widget get _animatedButtonUI => Container(
    height: widget.isFixedHeight ? 50.0 : null,
    width: widget.width,
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(100)),
        color: widget.color ?? Theme.of(context).primaryColor),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widget.icon != null
            ? Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Icon(
            widget.icon,
            color: Colors.white,
          ),
        )
            : SizedBox(),
        SizedBox(
          width: 5,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            '${widget.text}',
            // maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
