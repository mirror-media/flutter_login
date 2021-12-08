import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'login_helper.dart';

enum LoginType {
  facebook,
  google,
  apple,
}

class LoginButton extends StatefulWidget {
  final LoginType type;
  final FirebaseAuth auth;
  final void Function()? onSuccess;
  final void Function()? onFailed;
  final double textSize;
  final Color textColor;
  final bool showIcon;
  final Color buttonBackgroundColor;
  final Color buttonBorderColor;
  final Color loadingAnimationColor;
  const LoginButton({
    Key? key,
    required this.type,
    required this.auth,
    this.onSuccess,
    this.onFailed,
    this.textSize = 16,
    this.textColor = Colors.black,
    this.showIcon = true,
    this.buttonBackgroundColor = Colors.white,
    this.buttonBorderColor = Colors.black,
    this.loadingAnimationColor = Colors.black12,
  }) : super(key: key);

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;
  late String _buttonText;
  late Widget _icon;
  late LoginHelper _loginHelper;

  @override
  void initState() {
    _loginHelper = LoginHelper(widget.auth);
    if (widget.type == LoginType.apple) {
      _buttonText = '以 Apple 帳號繼續';
      _icon = const FaIcon(
        FontAwesomeIcons.apple,
        size: 18,
        color: Colors.black,
      );
    } else if (widget.type == LoginType.facebook) {
      _buttonText = '以 Facebook 帳號繼續';
      _icon = const FaIcon(
        FontAwesomeIcons.facebookSquare,
        size: 18,
        color: Color.fromRGBO(59, 89, 152, 1),
      );
    } else if (widget.type == LoginType.google) {
      _buttonText = '以 Google 帳號繼續';
      _icon = SvgPicture.asset(
        'assets/images/googleLogo.svg',
        package: 'flutter_login',
        width: 16,
        height: 16,
      );
    }

    if (!widget.showIcon) {
      _icon = Container();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        setState(() {
          _isLoading = true;
        });
        bool isSuccess;
        if (widget.type == LoginType.apple) {
          isSuccess = await _loginHelper.signInWithApple();
        } else if (widget.type == LoginType.facebook) {
          isSuccess = await _loginHelper.signInWithFacebook();
        } else {
          isSuccess = await _loginHelper.signInWithGoogle();
        }

        if (isSuccess && widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (!isSuccess && widget.onFailed != null) {
          widget.onFailed!();
        }
        setState(() {
          _isLoading = false;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: widget.buttonBackgroundColor,
        side: BorderSide(
          color: widget.buttonBorderColor,
          width: 1,
        ),
        fixedSize: const Size(double.infinity, 48),
      ),
      icon: _isLoading ? Container() : _icon,
      label: _isLoading
          ? SpinKitThreeBounce(color: widget.loadingAnimationColor, size: 30)
          : Text(
              _buttonText,
              style: TextStyle(
                fontSize: widget.textSize,
                fontWeight: FontWeight.w400,
                color: widget.textColor,
              ),
            ),
    );
  }
}
