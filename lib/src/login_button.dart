import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'login_helper.dart';

/// Supported third-party logins
enum LoginType {
  facebook,
  google,
  apple,
}

/// Return when login process finish with result
typedef LoginFinishCallback = void Function(
    FirebaseLoginStatus status, bool isNewUser, dynamic error);

class LoginButton extends StatefulWidget {
  /// Define button login type. Required
  final LoginType type;

  /// Execute when login process finish
  final LoginFinishCallback? onFinished;

  /// Customize button text
  /// <br>Default text:
  /// + Apple: 以 Apple 帳號繼續
  /// + Facebook: 以 Facebook 帳號繼續
  /// + Google: 以 Google 帳號繼續
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
  /// <br> Default is true
  /// <br> If true, when error occur, will pop a dialog and link new credential to existing firebase user
  /// <br> To know more, please read this [page](https://firebase.google.com/docs/auth/flutter/errors)
  final bool handleAccountExistsWithDifferentCredentialError;

  /// Customize button icon color.
  /// <br>Default color:
  /// + Apple: Black
  /// + Facebook: RGBO(23, 120, 242, 1)
  /// + Google: Colorful svg
  final Color? iconColor;

  /// Customize button icon. Default is logo by login type
  /// <br>This will place in OutlinedButton's icon
  final Widget? icon;

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
    this.handleAccountExistsWithDifferentCredentialError = true,
    this.iconColor,
    this.icon,
  }) : super(key: key);

  @override
  State<LoginButton> createState() => _LoginButtonState();
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
      _icon = FaIcon(
        FontAwesomeIcons.apple,
        size: 18,
        color: widget.iconColor ?? Colors.black,
      );
    } else if (widget.type == LoginType.facebook) {
      _buttonText = '以 Facebook 帳號繼續';
      _icon = FaIcon(
        FontAwesomeIcons.squareFacebook,
        size: 18,
        color: widget.iconColor ?? const Color.fromRGBO(23, 120, 242, 1),
      );
    } else if (widget.type == LoginType.google) {
      _buttonText = '以 Google 帳號繼續';
      _icon = SvgPicture.asset(
        'assets/images/googleLogo.svg',
        package: 'flutter_login',
        width: 16,
        height: 16,
        color: widget.iconColor,
      );
    }

    if (!widget.showIcon) {
      _icon = Container();
    }

    if (widget.buttonText != null) {
      _buttonText = widget.buttonText!;
    }

    if (widget.icon != null) {
      _icon = widget.icon!;
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
            handleAccountExistsWithDifferentCredentialError:
                widget.handleAccountExistsWithDifferentCredentialError,
          );
        } else if (widget.type == LoginType.facebook) {
          result = await _loginHelper.signInWithFacebook(
            handeAccountExistsWithDifferentCredentialError:
                widget.handleAccountExistsWithDifferentCredentialError,
          );
        } else {
          result = await _loginHelper.signInWithGoogle(
            handleAccountExistsWithDifferentCredentialError:
                widget.handleAccountExistsWithDifferentCredentialError,
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
