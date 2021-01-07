# pay_unit_sdk

A new Flutter package.




## To use this package, all you need to do is follow the instruction bellow .

## Add mavenCentral() to your project

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
## Add multiDexEnabled , update the minSdkVersion and implementation 'com.android.support:multidex:1.0.3' the to your project

Add multiDexEnabled true and implementation 'com.android.support:multidex:1.0.3' to your app/build.gradle file .
The minSdkVersion must be 19 and above

```


    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId "<Your app signature >"
        minSdkVersion 19
        targetSdkVersion 28
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true

    }



dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'com.android.support:multidex:1.0.3'
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
 	      text: "<Your Button text>",
              color: <Custom color of the button Example: Colors.red>,
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
