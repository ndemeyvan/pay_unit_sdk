import 'dart:async';

class PayUnitStream {

  /////////////////State controller
  final providerStreamController = StreamController<List>.broadcast();

  StreamSink<List> get setListProviderSink => providerStreamController.sink;

  Stream<List> get settListProviderStream => providerStreamController.stream;

  /////////////////State controller
  final paymentStreamController = StreamController<bool>.broadcast();

  StreamSink<bool> get paymentSink => paymentStreamController.sink;

  Stream<bool> get paymentStream => paymentStreamController.stream;



  void dispose() {
    providerStreamController.close();
    paymentStreamController.close();
    print("payUnitStream dispose");
  }
}

////////global instance
PayUnitStream payUnitStream = new PayUnitStream();
