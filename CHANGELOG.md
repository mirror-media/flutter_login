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
