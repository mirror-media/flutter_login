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
              onSuccess: (isNewUser) {
                if (auth.currentUser!.email != null) {
                  loginStauts = auth.currentUser!.email! + '\nlog in';
                  isLoggedIn = true;
                } else {
                  loginStauts = 'No email log in';
                }
                setState(() {});
              },
              onFailed: (error) {
                setState(() {
                  loginStauts = 'Log in failed';
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            LoginButton(
              type: LoginType.facebook,
              onSuccess: (isNewUser) {
                if (auth.currentUser!.email != null) {
                  loginStauts = auth.currentUser!.email! + '\nlog in';
                  isLoggedIn = true;
                } else {
                  loginStauts = 'No email log in';
                }
                setState(() {});
              },
              onFailed: (error) {
                setState(() {
                  loginStauts = 'Log in failed';
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            if (Platform.isIOS)
              LoginButton(
                type: LoginType.apple,
                onSuccess: (isNewUser) {
                  if (auth.currentUser!.email != null) {
                    loginStauts = auth.currentUser!.email! + '\nlog in';
                    isLoggedIn = true;
                  } else {
                    loginStauts = 'No email log in';
                  }
                  setState(() {});
                },
                onFailed: (error) {
                  setState(() {
                    loginStauts = 'Log in failed';
                  });
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
                    bool isSuccess = await _loginWithEmailAndPassword(
                        _controller1.text, _controller2.text);
                    if (isSuccess && auth.currentUser != null) {
                      if (auth.currentUser!.email != null) {
                        loginStauts = auth.currentUser!.email! + '\nlog in';
                        isLoggedIn = true;
                      } else {
                        loginStauts = 'No email log in';
                      }
                      setState(() {});
                    } else {
                      setState(() {
                        loginStauts = 'Log in failed';
                      });
                    }
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

  Future<bool> _loginWithEmailAndPassword(String email, String password) async {
    bool isSuccess = await loginHelper.signInWithEmailAndPassword(
      email,
      password,
      context: context,
      askAgain: true,
    );
    return isSuccess;
  }
}
