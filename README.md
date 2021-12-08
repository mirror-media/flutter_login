<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A Flutter package provide third party login buttons and helper to use firebase auth.
## Notices

Before use this package, make sure you have already set up your Firebase and settings of below packages.
1. [google_sign_in](https://pub.dev/packages/google_sign_in)
2. [flutter_facebook_auth](https://facebook.meedu.app/docs/intro)
3. [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple) (Only use on iOS now.)

## Features

1. Login button which already define for Google, Facebook, and Apple sign in.
2. You can pass function that executes when login is successful or failure.
3. Use LoginHelper to send user a passwordless login email.

## Getting started

1. Add below lines to your project's pubspec.yaml dependencies.

flutter_login:
    git:
      url: https://github.com/mirror-media/flutter_login.git
      ref: main
      version: ^0.0.1

2. Import library by adding the following line to where you want to use button or helper.
```dart
import 'package:flutter_login/flutter_login.dart';
```

## Usage 
Login type:
```dart
enum LoginType {
  facebook,
  google,
  apple,
}
```

Login button widget:
```dart
LoginButton(
type: LoginType // LoginType is required, others are optional
onSuccess: Function? //Do after login success
onFailed: Function? //Do after login failed
textSize: double    // Change the text size of the LoginButton, default is 16.0
textColor: Color    // Change the text color of the LoginButton, default is Colors.black
showIcon: bool      // Whether or not show the icon, default is true
buttonBackgroundColor: Color    // Change the background color of the LoginButton, default is Colors.white
buttonBorderColor: Color    // Change the border color of the LoginButton, default is Colors.black
loadingAnimationColor: Color    // Change the loading animation color of the LoginButton, default is Colors.black12
);
```

Login helper:
There are 4 main functions.
All of them are Future and will return a bool that indicates whether or not the user is logged in successfully.

1. signInWithEmailAndLink:
```dart
Future<bool> signInWithEmailAndLink(String email, String link)
```
email is the email address that will be sent to, link is the user will be redirected to when there is no application.
Notice: It will save the email by used SharedPreferences with key "signInEmail", you will need to get it from shared preferences when the user open the application from login email to verify.

2. signInWithGoogle:
```dart
Future<bool> signInWithGoogle()
```

3. signInWithFacebook:
```dart
Future<bool> signInWithFacebook()
```

4. signInWithApple:
```dart
Future<bool> signInWithApple()
```
