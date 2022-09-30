// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:one_context/one_context.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Return firebase_auth login result
enum FirebaseLoginStatus {
  cancel,
  success,
  error,
}

class LoginHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserCredential _userCredential;

  /// Get whether current user is new user from Firebase auth
  /// <br> **Use this value after login is successful**
  bool isNewUser = false;

  /// Get error when login
  /// <br> **May get null when no error or still in process**
  dynamic error;

  /// Sign in to Firebase with email and link
  /// <br> This function only send email, you need to handle login dynamic link yourself
  Future<bool> signInWithEmailAndLink(String email, String link) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var acs = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
      url: link,
      // This must be true
      handleCodeInApp: true,
      iOSBundleId: packageInfo.packageName,
      androidPackageName: packageInfo.packageName,
      // installIfNotAvailable
      androidInstallApp: true,
    );

    bool isSuccess = false;
    await _auth
        .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
        .catchError((onError) {
      print('Error sending email verification $onError');
    }).then((value) async {
      print('Successfully sent email verification');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('signInEmail', email);
      isSuccess = true;
    });
    return isSuccess;
  }

  /// Sign in to Firebase with Google
  Future<FirebaseLoginStatus> signInWithGoogle({
    bool handleAccountExistsWithDifferentCredentialError = true,
  }) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return FirebaseLoginStatus.cancel;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      _userCredential = await _auth.signInWithCredential(credential);
      isNewUser = _userCredential.additionalUserInfo?.isNewUser ?? false;

      return FirebaseLoginStatus.success;
    } on FirebaseAuthException catch (e) {
      error = e;
      print('SignInWithGoogle failed error code: ${e.code}');
      print(e.message);
      if (!handleAccountExistsWithDifferentCredentialError) {
        return FirebaseLoginStatus.error;
      }
      if (e.code == 'account-exists-with-different-credential') {
        return await _accountExists(e);
      } else {
        return FirebaseLoginStatus.error;
      }
    } catch (e) {
      error = e;
      print('SignInWithGoogle failed: ${e.toString()}');
      return FirebaseLoginStatus.error;
    }
  }

  /// Sign in to Firebase with Facebook
  Future<FirebaseLoginStatus> signInWithFacebook({
    bool handeAccountExistsWithDifferentCredentialError = true,
  }) async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);
        // Once signed in, return the UserCredential
        _userCredential = await _auth.signInWithCredential(credential);
        isNewUser = _userCredential.additionalUserInfo?.isNewUser ?? false;
        return FirebaseLoginStatus.success;
      } else if (loginResult.status == LoginStatus.cancelled) {
        return FirebaseLoginStatus.cancel;
      } else {
        return FirebaseLoginStatus.error;
      }
    } on FirebaseAuthException catch (e) {
      error = e;
      print('SignInWithFacebook failed error code: ${e.code}');
      print(e.message);
      if (!handeAccountExistsWithDifferentCredentialError) {
        return FirebaseLoginStatus.error;
      }
      if (e.code == 'account-exists-with-different-credential') {
        return await _accountExists(e);
      } else {
        return FirebaseLoginStatus.error;
      }
    } catch (e) {
      error = e;
      print('SignInWithFacebook failed: ${e.toString()}');
      return FirebaseLoginStatus.error;
    }
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in to Firebase with Apple
  Future<FirebaseLoginStatus> signInWithApple({
    bool handleAccountExistsWithDifferentCredentialError = true,
  }) async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    try {
      final rawNonce = generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      _userCredential = await _auth.signInWithCredential(oauthCredential);
      isNewUser = _userCredential.additionalUserInfo?.isNewUser ?? false;
      return FirebaseLoginStatus.success;
    } on FirebaseAuthException catch (e) {
      error = e;
      print('signInWithApple failed error code: ${e.code}');
      print(e.message);
      if (!handleAccountExistsWithDifferentCredentialError) {
        return FirebaseLoginStatus.error;
      }
      if (e.code == 'account-exists-with-different-credential') {
        return await _accountExists(e);
      } else {
        return FirebaseLoginStatus.error;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return FirebaseLoginStatus.cancel;
      }
      return FirebaseLoginStatus.error;
    } catch (e) {
      error = e;
      print('signInWithApple failed: ${e.toString()}');
      return FirebaseLoginStatus.error;
    }
  }

  /// Create new user in Firebase with email and password
  Future<FirebaseLoginStatus> createUserWithEmailAndPassword(
    String email,
    String password, {
    bool ifExistsTrySignIn = true,
  }) async {
    try {
      _userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      isNewUser = _userCredential.additionalUserInfo?.isNewUser ?? false;
      return FirebaseLoginStatus.success;
    } on FirebaseAuthException catch (e) {
      error = e;
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        if (ifExistsTrySignIn) {
          return await signInWithEmailAndPassword(
            email,
            password,
          );
        }
      }
      return FirebaseLoginStatus.error;
    } catch (e) {
      error = e;
      print(e);
      return FirebaseLoginStatus.error;
    }
  }

  /// Sign in to Firebase with email and password
  Future<FirebaseLoginStatus> signInWithEmailAndPassword(
    String email,
    String password, {
    bool ifNotExistsCreateUser = true,
    bool askAgain = false,
  }) async {
    try {
      _userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      isNewUser = _userCredential.additionalUserInfo?.isNewUser ?? false;
      return FirebaseLoginStatus.success;
    } on FirebaseAuthException catch (e) {
      error = e;
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        if (ifNotExistsCreateUser) {
          return await createUserWithEmailAndPassword(
            email,
            password,
          );
        }
      } else if (e.code == 'wrong-password') {
        List<String> userSignInMethods =
            await _auth.fetchSignInMethodsForEmail(email);
        if (userSignInMethods.isNotEmpty &&
            !userSignInMethods.contains('password')) {
          return await _updateAccountPassword(
            email,
            password,
            userSignInMethods,
          );
        } else if (askAgain) {
          print('Wrong password provided for that user.');
          String? newPassword = await _askUserKeyPassword(
            email,
            isTryAgain: true,
          );
          if (newPassword == null) {
            return FirebaseLoginStatus.cancel;
          } else {
            return await signInWithEmailAndPassword(
              email,
              newPassword,
              askAgain: askAgain,
            );
          }
        }
      }
      return FirebaseLoginStatus.error;
    }
  }

  Future<FirebaseLoginStatus> _updateAccountPassword(
    String email,
    String password,
    List<String> userSignInMethods,
  ) async {
    FirebaseLoginStatus result = FirebaseLoginStatus.error;

    if (userSignInMethods.first == 'facebook.com') {
      await _showErrorHint(
        'Facebook',
        email,
        isUpdatePassword: true,
      );

      result = await signInWithFacebook();
    } else if (userSignInMethods.first == 'apple.com') {
      await _showErrorHint(
        'Apple',
        email,
        isUpdatePassword: true,
      );
      result = await signInWithApple();
    } else if (userSignInMethods.first == 'google.com') {
      await _showErrorHint(
        'Google',
        email,
        isUpdatePassword: true,
      );
      result = await signInWithGoogle();
    } else {
      print('no sign in method already exists');
    }
    if (result == FirebaseLoginStatus.success) {
      try {
        _userCredential.user!.updatePassword(password);
      } on FirebaseAuthException catch (e) {
        error = e;
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        }
      } catch (e) {
        print('Update password failed: $e');
      }
    }
    return result;
  }

  Future<FirebaseLoginStatus> _accountExists(
    FirebaseAuthException e,
  ) async {
    if (e.email == null || e.credential == null) {
      print('email or credential is missing');
      return FirebaseLoginStatus.error;
    }
    // The account already exists with a different credential
    String email = e.email!;
    AuthCredential pendingCredential = e.credential!;

    // Fetch a list of what sign-in methods exist for the conflicting user
    List<String> userSignInMethods =
        await _auth.fetchSignInMethodsForEmail(email);
    FirebaseLoginStatus result = FirebaseLoginStatus.error;

    if (userSignInMethods.first == 'facebook.com') {
      await _showErrorHint('Facebook', email);
      result = await signInWithFacebook();
    } else if (userSignInMethods.first == 'apple.com') {
      _showErrorHint('Apple', email);
      result = await signInWithApple();
    } else if (userSignInMethods.first == 'google.com') {
      await _showErrorHint('Google', email);
      result = await signInWithGoogle();
    } else if (userSignInMethods.first == 'password') {
      String? newPassword = await _askUserKeyPassword(email);
      if (newPassword != null) {
        result = await signInWithEmailAndPassword(
          email,
          newPassword,
          askAgain: true,
        );
      }
    } else {
      print('no sign in method already exists');
    }
    if (result == FirebaseLoginStatus.success) {
      // Link the pending credential with the existing account
      _userCredential =
          await _userCredential.user!.linkWithCredential(pendingCredential);
      isNewUser = _userCredential.additionalUserInfo?.isNewUser ?? false;
    }
    return result;
  }

  dynamic get signinError => error;

  Future<void> _showErrorHint(
    String loginType,
    String email, {
    bool isUpdatePassword = false,
  }) async {
    String title = '曾使用$loginType登入';
    String message =
        '由於$email曾使用$loginType登入，故麻煩您接下來先以$loginType登入$email以連結帳戶\n\n連結成功後未來即可使用此登入方式';
    if (isUpdatePassword) {
      message =
          '由於$email曾使用$loginType登入，故麻煩您接下來先以$loginType登入$email以新增密碼\n\n登入成功後未來即可使用此密碼登入';
    }

    Widget dialog;
    if (Platform.isIOS) {
      dialog = CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('確定'),
            onPressed: () => OneContext().pop(),
          )
        ],
      );
    } else {
      dialog = AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => OneContext().pop(),
            child: const Text('確定'),
          )
        ],
      );
    }
    await OneContext().showDialog(builder: (context) => dialog);
  }

  Future<String?> _askUserKeyPassword(
    String email, {
    bool isTryAgain = false,
  }) async {
    String? password;
    String title = '曾使用Email與密碼登入';
    String content =
        '由於$email曾使用Email與密碼登入，故麻煩您輸入密碼登入$email以連結帳戶\n\n連結成功後未來即可使用此登入方式';
    if (isTryAgain) {
      title = '密碼錯誤';
      content = '請重新輸入密碼';
    }
    Widget dialog;
    if (Platform.isIOS) {
      dialog = StatefulBuilder(builder: (context, setState) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Column(
            children: [
              Text(content),
              const SizedBox(
                height: 10,
              ),
              CupertinoTextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                    if (password == '' || password == ' ') {
                      password = null;
                    }
                  });
                },
                placeholder: "請輸入密碼",
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            CupertinoDialogAction(
              onPressed:
                  password == null ? null : () => Navigator.of(context).pop(),
              child: const Text('確定'),
            ),
          ],
        );
      });
    } else {
      dialog = StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content),
              const SizedBox(
                height: 10,
              ),
              TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                    if (password == '' || password == ' ') {
                      password = null;
                    }
                  });
                },
                decoration: const InputDecoration(hintText: "請輸入密碼"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed:
                  password == null ? null : () => Navigator.of(context).pop(),
              child: const Text('確定'),
            ),
          ],
        );
      });
    }

    await OneContext().showDialog(builder: (context) => dialog);

    if (password == '' || password == ' ') {
      password = null;
    }
    return password;
  }
}
