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
# Notices

Before use this package, make sure you have already set up your Firebase and settings of below packages.
1. [google_sign_in](https://pub.dev/packages/google_sign_in)
2. [flutter_facebook_auth](https://facebook.meedu.app/docs/intro)
3. [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)

# Features

1. Login button which already define for Google, Facebook, and Apple sign in.
2. You can pass function that executes when login is successful or failure.
3. Use LoginHelper to send user a passwordless login email.
4. Use LoginHelper to sign in or create new firebase user with email and password.

# Getting started

1. Add below lines to your project's pubspec.yaml dependencies.

```yaml
flutter_login:
    git:
      url: https://github.com/mirror-media/flutter_login.git
      ref: main
      version: ^0.0.9
```

2. Import library by adding the following line to where you want to use button or helper.
```dart
import 'package:flutter_login/flutter_login.dart';
```

# Usage 
## Login type:
Supported third-party logins
```dart
enum LoginType {
  facebook,
  google,
  apple,
}
```
## Login Status:
 Return firebase_auth login result
```dart
enum FirebaseLoginStatus {
  cancel,
  success,
  error,
}
```

## class LoginButton:

A prebuild button widget for each LoginType.

```dart
/// Define button login type. Required
final LoginType type;

/// Execute when login process finish
final LoginFinishCallback? onFinished;

/// Customize button text
/// Default text:
/// Apple: 以 Apple 帳號繼續
/// Facebook: 以 Facebook 帳號繼續
/// Google: 以 Google 帳號繼續
final String? buttonText;

/// Customize button text size. Default is 16.0
final double textSize;

/// Customize button text color. Default is black
final Color textColor;

/// Whether to show the icon. Default is true
final bool showIcon;

/// Customize button backgroundColor. Default is white
final Color buttonBackgroundColor;

/// Customize button borderColor. Default is black
final Color buttonBorderColor;

/// Customize button loading animation color. Default is black12
final Color loadingAnimationColor;

/// Whether to handle Firebase's "account-exists-with-different-credential" error
/// Default is true
/// If true, when error occur, will pop a dialog and link new credential to existing firebase user
/// To know more, please read this [page](https://firebase.google.com/docs/auth/flutter/errors)
final bool handleAccountExistsWithDifferentCredentialError;

/// Customize button icon color.
/// Default color:
/// Apple: Black
/// Facebook: RGBO(23, 120, 242, 1)
/// Google: Colorful svg
final Color? iconColor;

/// Customize button icon. Default is logo by login type
/// This will place in OutlinedButton's icon
final Widget? icon;
```

## class LoginHelper:

There are 4 main usage.

All of them are Future and will return a boolean that indicates whether or not the user is log in (or create) successfully.

<br />

### 1. Send a email with link for passwordless login:
```dart
Future<bool> signInWithEmailAndLink(String email, String link)
```
email is the email address that will be sent to, link is the user will be redirected to when there is no application.

**Notice: It will save the email as String by used SharedPreferences with key "signInEmail", you will need to get it from shared preferences when the user open the application from login email to verify.**

**Notice 2: If you want to use this sign in method, you need to open passwordless sign in in firebase console.**

<br />

### 2. Third party sign in:

Now support Google, Facebook, and Apple.

They have same optional named parameter: handleAccountExistsWithDifferentCredentialError.

- handleAccountExistsWithDifferentCredentialError: Decide whether or not handle account-exists-with-different-credential error, default is true.
<br />

signInWithGoogle:
```dart
Future<FirebaseLoginStatus> signInWithGoogle({
  bool handleAccountExistsWithDifferentCredentialError = true,
})
```
signInWithFacebook:
```dart
Future<FirebaseLoginStatus> signInWithFacebook({
  bool handleAccountExistsWithDifferentCredentialError = true,
})
```
signInWithApple:
```dart
Future<FirebaseLoginStatus> signInWithApple({
  bool handleAccountExistsWithDifferentCredentialError = true,
})
```
<br />

### 3. Email and password sign in:

There are two parameter: email and password. And optional named parameters:  ifNotExistsCreateUser, askAgain.

- ifNotExistsCreateUser: Decide if can't find user whether directly create one new user via createUserWithEmailAndPassword(), default is true.
- askAgain: Decide whether show a dialog when user password not correct, default is false. 


```dart
Future<FirebaseLoginStatus> signInWithEmailAndPassword(
  String email,
  String password, {
  bool ifNotExistsCreateUser = true,
  bool askAgain = false,
})
```

<br />

### 4. Create new user with email and password:

There are two parameter: email and password. And optional named parameters:  ifExistsTrySignIn.

- ifExistsTrySignIn: Decide if email is already exists, whether directly try sign in, default is true.

```dart
Future<FirebaseLoginStatus> createUserWithEmailAndPassword(
  String email,
  String password, {
  bool ifExistsTrySignIn = true,
})
```
<br />

### 'account-exists-with-different-credential' error

It will occur when user already exists in Firebase auth. 
<br>By default this package will handle this error by show a dialog and ask user to sign in with default sign in method provide by Firebase, then link currrent sign in method to Firebase auth.
<br> To know more, please check this [page](https://firebase.google.com/docs/auth/flutter/errors).

<br>

### Others:

It has two getter, isNewUser and signinError.

- isNewUser: It will return a boolean indicating whether user is new.

  **Notice: Only use after signIn successfully, or may get error value**


- signinError: It will return dynamic that previous sign in method catch error.

  **Notice: Only use after signIn failed, or may get null**
