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

typedef LoginFinishCallback = void Function(
    FirebaseLoginStatus status, bool isNewUser, dynamic error);

class LoginButton extends StatefulWidget {
  final LoginType type;
  final LoginFinishCallback? onFinished;
  final String? buttonText;
  final double textSize;
  final Color textColor;
  final bool showIcon;
  final Color buttonBackgroundColor;
  final Color buttonBorderColor;
  final Color loadingAnimationColor;
  final bool handlingAccountExistsWithDifferentCredentialError;
  const LoginButton({
    Key? key,
    required this.type,
    this.onFinished,
    this.buttonText,
    this.textSize = 16,
    this.textColor = Colors.black,
    this.showIcon = true,
    this.buttonBackgroundColor = Colors.white,
    this.buttonBorderColor = Colors.black,
    this.loadingAnimationColor = Colors.black12,
    this.handlingAccountExistsWithDifferentCredentialError = true,
  }) : super(key: key);

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;
  late String _buttonText;
  late Widget _icon;
  final LoginHelper _loginHelper = LoginHelper();

  @override
  void initState() {
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

    if (widget.buttonText != null) {
      _buttonText = widget.buttonText!;
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
        FirebaseLoginStatus result;
        if (widget.type == LoginType.apple) {
          result = await _loginHelper.signInWithApple(
            handlingAccountExistsWithDifferentCredentialError:
                widget.handlingAccountExistsWithDifferentCredentialError,
            context: context,
          );
        } else if (widget.type == LoginType.facebook) {
          result = await _loginHelper.signInWithFacebook(
            handlingAccountExistsWithDifferentCredentialError:
                widget.handlingAccountExistsWithDifferentCredentialError,
            context: context,
          );
        } else {
          result = await _loginHelper.signInWithGoogle(
            handlingAccountExistsWithDifferentCredentialError:
                widget.handlingAccountExistsWithDifferentCredentialError,
            context: context,
          );
        }

        if (widget.onFinished != null) {
          widget.onFinished!(
            result,
            _loginHelper.isNewUser,
            _loginHelper.error,
          );
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
