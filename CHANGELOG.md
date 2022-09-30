## 0.0.9

- Add one_context package to remove context in async functions
- Add optional parameter icon and iconColor to LoginButton
- Add comments to function and parameters
- Upgrade example to Flutter 3

**BREAKING CHANGE:**
- **Refactor: change paramter name from "handlingAccountExistsWithDifferentCredentialError" to "handleAccountExistsWithDifferentCredentialError"**
- **Remove context in function's parameter**

## 0.0.8

- Upgrade sign_in_with_apple to ^4.1.0
- Upgrade font_awesome_flutter to ^10.2.1
- Upgrade flutter_lints to ^2.0.1


## 0.0.6

- Upgrade flutter_facebook_auth to ^4.1.2
- Upgrade firebase_auth to ^3.3.11
- Upgrade sign_in_with_apple to ^3.3.0
- Upgrade google_sign_in to ^5.2.4
- Upgrade package_info_plus to ^1.4.0
- Upgrade flutter_svg to ^1.0.3
- Upgrade shared_preferences to ^2.0.13

**BREAKING CHANGE:**
- **Add enum FirebaseLoginStatus**
- **Change login_helper return type to enum FirebaseLoginStatus**
- **Change login_button parameter onSuccess and onFailed to onFinished**



## 0.0.5

- Upgrade flutter_facebook_auth to ^4.1.1


## 0.0.4

- Add example app connect to MirrorMedia App Dev firebase.
- Handle error when user want login that email is existed but no password.
- Ask user key password again when linking existed email.


## 0.0.3

- Parameter onFailed of LoginButton now will pass the error into function.
- LoginButton add a parameter 'buttonText' let you custom the text.
- LoginButton add a parameter 'handlingAccountExistsWithDifferentCredentialError' to decide whether handle 'account-exists-with-different-credential' error.
- Show a hint dialog when account-exists-with-different-credential error happen.
- Remove unnecessary function generateNonce in LoginHelper.
- Add createUserWithEmailAndPassword() and signInWithEmailAndPassword() in LoginHelper.
- Now can handle 'account-exists-with-different-credential' error.


## 0.0.2

- Change onSuccess in LoginButton to valueSetter with a boolean isNewUser.
- Add error handler for 'account-exists-with-different-credential' error. (BETA)


## 0.0.1

- Outlined button with three style (Google, Facebook and Apple).
- A helper that contains sign in function.
