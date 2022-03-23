import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'flutter_login_example',
      home: TestApp(),
    );
  }
}

class TestApp extends StatefulWidget {
  const TestApp({Key? key}) : super(key: key);
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  String loginStauts = "none";
  FirebaseAuth auth = FirebaseAuth.instance;
  LoginHelper loginHelper = LoginHelper();

  @override
  Widget build(BuildContext context) {
    // force portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    TextEditingController _controller1 = TextEditingController();
    TextEditingController _controller2 = TextEditingController();
    bool isLoggedIn = false;
    if (auth.currentUser != null) {
      isLoggedIn = true;
      loginStauts = auth.currentUser!.email! + '\nlog in';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_login_example'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          children: [
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                'Login status',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Center(
              child: Text(
                loginStauts,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            LoginButton(
              type: LoginType.google,
              onFinished: (status, isNewUser, error) {
                if (status == FirebaseLoginStatus.success) {
                  loginStauts = auth.currentUser!.email! + '\nlog in';
                  isLoggedIn = true;
                } else if (status == FirebaseLoginStatus.cancel) {
                  loginStauts = 'Login cancelled';
                } else {
                  loginStauts = 'Log in failed';
                }
                setState(() {});
              },
            ),
            const SizedBox(
              height: 10,
            ),
            LoginButton(
              type: LoginType.facebook,
              onFinished: (status, isNewUser, error) {
                if (status == FirebaseLoginStatus.success) {
                  loginStauts = auth.currentUser!.email! + '\nlog in';
                  isLoggedIn = true;
                } else if (status == FirebaseLoginStatus.cancel) {
                  loginStauts = 'Login cancelled';
                } else {
                  loginStauts = 'Log in failed';
                }
                setState(() {});
              },
            ),
            const SizedBox(
              height: 10,
            ),
            if (Platform.isIOS)
              LoginButton(
                type: LoginType.apple,
                onFinished: (status, isNewUser, error) {
                  if (status == FirebaseLoginStatus.success) {
                    loginStauts = auth.currentUser!.email! + '\nlog in';
                    isLoggedIn = true;
                  } else if (status == FirebaseLoginStatus.cancel) {
                    loginStauts = 'Login cancelled';
                  } else {
                    loginStauts = 'Log in failed';
                  }
                  setState(() {});
                },
              ),
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: Text('Email'),
            ),
            TextField(
              controller: _controller1,
            ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text('Password'),
            ),
            TextField(
              controller: _controller2,
            ),
            const SizedBox(
              height: 10,
            ),
            if (!isLoggedIn)
              ElevatedButton(
                onPressed: () async {
                  if (EmailValidator.validate(_controller1.text)) {
                    FirebaseLoginStatus status =
                        await _loginWithEmailAndPassword(
                            _controller1.text, _controller2.text);
                    if (status == FirebaseLoginStatus.success) {
                      loginStauts = auth.currentUser!.email! + '\nlog in';
                      isLoggedIn = true;
                    } else if (status == FirebaseLoginStatus.cancel) {
                      loginStauts = 'Login cancelled';
                    } else {
                      loginStauts = 'Log in failed';
                    }
                    setState(() {});
                  } else {
                    setState(() {
                      loginStauts = 'Please enter a valid email';
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () async {
                  await auth.signOut();
                  setState(() {
                    isLoggedIn = false;
                    loginStauts = "none";
                  });
                },
                child: const Text('Log out'),
              )
          ],
        ),
      ),
    );
  }

  Future<FirebaseLoginStatus> _loginWithEmailAndPassword(
      String email, String password) async {
    return await loginHelper.signInWithEmailAndPassword(
      email,
      password,
      context: context,
      askAgain: true,
    );
  }
}
