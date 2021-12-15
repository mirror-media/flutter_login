// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginHelper {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late UserCredential userCredential;

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
    await auth
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

  Future<bool> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      userCredential = await auth.signInWithCredential(credential);

      return true;
    } on FirebaseAuthException catch (e) {
      print('SignInWithGoogle failed error code: ${e.code}');
      print(e.message);
      if (e.code == 'account-exists-with-different-credential') {
        return await accountExists(e);
      } else {
        return false;
      }
    } catch (e) {
      print('SignInWithGoogle failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);
        // Once signed in, return the UserCredential
        userCredential = await auth.signInWithCredential(credential);
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('SignInWithFacebook failed error code: ${e.code}');
      print(e.message);
      if (e.code == 'account-exists-with-different-credential') {
        return await accountExists(e);
      } else {
        return false;
      }
    } catch (e) {
      print('SignInWithFacebook failed: ${e.toString()}');
      return false;
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

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
      userCredential = await auth.signInWithCredential(oauthCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      print('signInWithApple failed error code: ${e.code}');
      print(e.message);
      if (e.code == 'account-exists-with-different-credential') {
        return await accountExists(e);
      } else {
        return false;
      }
    } catch (e) {
      print('signInWithApple failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> accountExists(FirebaseAuthException e) async {
    if (e.email == null || e.credential == null) {
      print('email or credential is missing');
      return false;
    }
    // The account already exists with a different credential
    String email = e.email!;
    AuthCredential pendingCredential = e.credential!;

    // Fetch a list of what sign-in methods exist for the conflicting user
    List<String> userSignInMethods =
        await auth.fetchSignInMethodsForEmail(email);

    if (userSignInMethods.first == 'facebook.com') {
      bool isSuccess = await signInWithFacebook();
      if (!isSuccess) return false;

      // Link the pending credential with the existing account
      userCredential =
          await userCredential.user!.linkWithCredential(pendingCredential);
      return true;
    } else if (userSignInMethods.first == 'apple.com') {
      bool isSuccess = await signInWithApple();
      if (!isSuccess) return false;

      // Link the pending credential with the existing account
      userCredential =
          await userCredential.user!.linkWithCredential(pendingCredential);
      return true;
    } else if (userSignInMethods.first == 'google.com') {
      bool isSuccess = await signInWithGoogle();
      if (!isSuccess) return false;

      // Link the pending credential with the existing account
      userCredential =
          await userCredential.user!.linkWithCredential(pendingCredential);
      return true;
    } else {
      print('other sign in method already exists');
      return false;
    }
  }

  bool get isNewUser => userCredential.additionalUserInfo!.isNewUser;
}
