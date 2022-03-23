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
3. [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple) (Should only use on iOS now.)

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
      version: ^0.0.6
```

2. Import library by adding the following line to where you want to use button or helper.
```dart
import 'package:flutter_login/flutter_login.dart';
```

# Usage 
## Login type:
```dart
enum LoginType {
  facebook,
  google,
  apple,
}
```
## Login Status:
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
Widget LoginButton({
// LoginType is required, others are optional
type: LoginType

// Do after login
onFinished: Function(FirebaseLoginStatus result, bool isNewUser, dynamic error)? 

// Pass the String if you want to customize the button text
buttonText: String?

// Change the text size of the LoginButton, default is 16.0
textSize: double

// Change the text color of the LoginButton, default is Colors.black
textColor: Color

// Whether or not show the icon, default is true
showIcon: bool

// Change the background color of the LoginButton, default is Colors.white
buttonBackgroundColor: Color

// Change the border color of the LoginButton, default is Colors.black
buttonBorderColor: Color

// Change the loading animation color of the LoginButton, default is Colors.black12
loadingAnimationColor: Color

// Whether or not handle account-exists-with-different-credential error, default is true
handlingAccountExistsWithDifferentCredentialError: bool
});
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

They have same optional named parameter, handlingAccountExistsWithDifferentCredentialError and context.

- handlingAccountExistsWithDifferentCredentialError: Decide whether or not handle account-exists-with-different-credential error, default is true.
- context: It's for show the hint dialog when account-exists-with-different-credential error happened, when it is null, dialog will not be shown.
<br />

signInWithGoogle:
```dart
Future<FirebaseLoginStatus> signInWithGoogle({
  bool handlingAccountExistsWithDifferentCredentialError = true,
  BuildContext? context,
})
```
signInWithFacebook:
```dart
Future<FirebaseLoginStatus> signInWithFacebook({
  bool handlingAccountExistsWithDifferentCredentialError = true,
  BuildContext? context,
})
```
signInWithApple:
```dart
Future<FirebaseLoginStatus> signInWithApple({
  bool handlingAccountExistsWithDifferentCredentialError = true,
  BuildContext? context,
})
```
<br />

### 3. Email and password sign in:

There are two parameter: email and password. And three optional named parameters:  ifNotExistsCreateUser, askAgain, context.

- ifNotExistsCreateUser: Decide if can't find user whether directly create one new user via createUserWithEmailAndPassword(), default is true.
- askAgain: Decide whether show a dialog when user password not correct, default is false. 

  **Because it will show dialog, context must be set, or it will be ignored.**
- context: BuildContext for show dialog.

```dart
Future<FirebaseLoginStatus> signInWithEmailAndPassword(
  String email,
  String password, {
  bool ifNotExistsCreateUser = true,
  bool askAgain = false,
  BuildContext? context,
})
```

<br />

### 4. Create new user with email and password:

There are two parameter: email and password. And two optional named parameters:  ifExistsTrySignIn, context.

- ifExistsTrySignIn: Decide if email is already exists, whether directly try sign in, default is true.
- context: BuildContext for show dialog, only use for signInWithEmailAndPassword() when ifExistsTrySignIn is true.

```dart
Future<FirebaseLoginStatus> createUserWithEmailAndPassword(
  String email,
  String password, {
  bool ifExistsTrySignIn = true,
  BuildContext? context,
})
```
<br />

### Others:

It has two getter, isNewUser and signinError.

- isNewUser: It will return a boolean indicating whether user is new.

  **Notice: Only use after signIn successfully, or may get error**


- signinError: It will return dynamic that previous sign in method catch error.

  **Notice: Only use after signIn failed, or may get null**
