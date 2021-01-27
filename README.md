# pay_unit_sdk

A new Flutter package.




## To use this package, all you need to do is follow the instruction bellow .

## Use flutter sdk v.1.22.0 +

## Add mavenCentral() to your project .

Add mavenCentral() to allprojects in gradle > build.gradle .



```
allprojects {
    repositories {
        google()
        mavenCentral() <---
        jcenter()
    }
}

```


## Add Pay unit to your app .


```
 PayUnitButton(
	      apiKey: "<Your apiKey>",
              apiUser: "<Your apiuser>",
              apiPassword: "<Your apiPassword>",
              sandbox: '<Your usage mode>', // 'sandbox' or 'live' for production mode
              transactionCallBackUrl: "<Your transactionCallBackUrl url>",
              notiFyUrl: "<Your notification url>",
              transactionAmount: "<Your transaction amount>",
              color: <Custom color of the button Example: Colors.red>,
              productName: <The name of the product>,
              actionAfterProccess: (transactionId,  transactionStatus) {
		//here is the action who start after the end of the paiement , you can perform 	
		//some operation here , like display a alertDialog after the end of the payment.
                    AwesomeDialog(
                        dismissOnBackKeyPress: false,
                        dismissOnTouchOutside: false,
                        context: context,
                        dialogType: DialogType.SUCCES,
                        animType: AnimType.BOTTOMSLIDE,
                        title: "Pay unit",
                        desc: "Your transaction : $transactionId was successful",
                        btnOkColor: Colors.green,
                        btnOkText: "Continue",
                        btnOkOnPress: () async {
                        })
                      ..show();
		//Here we use Awesome dialog package to display a success message of the paiment
              },
            ),

```
