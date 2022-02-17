# pay_unit_sdk

A Pay unit sdk package.


<img width="1151" alt="shot" src="https://user-images.githubusercontent.com/44162391/122916187-88287b00-d354-11eb-959b-fca45e291254.png">


## NEW Pay_unit_sdk VERSION 2.0.7 ==> Support Flutter 2.x .
## FOR FLUTTER VERSION < 2.x ==> 2.0.4 without Cupertino package because the package already has it .


## To use this package, all you need to do is follow the instruction bellow ,  Please Download the recent version of the SDK .

## Use flutter sdk v.1.22.0 +

##  minSdkVersion 19

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


## Make sure the icon of your app is locate is like @mipmap/ic_launcher . to get the PayUnit sdk notification in your app after every transaction


## Add Pay unit to your app .

## Add // @dart=2.9 to your main.dart before importation list to avoid null-safety
 .


```
// @dart=2.9 <-- put this to your main.dart before importation list to avoid null-safety
import ....
        .
        .
        .
        .
        .
         PayUnitButton(
              apiUser:"<Your apiuser>",
              apiPassword:  "<Your apiPassword>",
              apiKey: "<Your apiKey>",
              transactionId: "<The id of your transaction>",
              mode: 'sandbox' // sandbox or live,
              transactionCallBackUrl:"<Your transactionCallBackUrl url>",
              notiFyUrl: "<Your notification url>",
              transactionAmount:  "<Your transaction amount>",
              currency:"XAF", //// The currency of your transaction : XAF for FCFA or USD for $ ect ...
              buttonTextColor:  "<Custom the color of the text PayUnit button>",
              productName:"<The name of the product>",
              color: "<Custom the color of PayUnit button>",///the colors of the PayUnit Button text DEFAULT WHITE,
              actionAfterProccess: (transactionId, transactionStatus) {
               //here is the action who start after the end of the paiement , you can perform 	
               //some operation here , like display a alertDialog after the end of the payment.
              },
          ),
![gallery - Copy](https://user-images.githubusercontent.com/44162391/154532487-6d2723f3-8b9b-4b12-a534-8923205f51c5.png)




<img width="1920" alt="clients - Copy" src="https://user-images.githubusercontent.com/44162391/154532588-496e4fd0-8d2e-443d-bd53-94814ff1f229.png">










```
