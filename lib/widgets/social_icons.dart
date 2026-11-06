import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand icons for the social sign-in buttons — the official
/// Google "G" and Facebook "f" logos (SVG assets in assets/icons/).
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key, this.size = 21});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/google.svg',
      width: size,
      height: size,
    );
  }
}

/// The official Facebook "f" logo in brand blue.
class FacebookIcon extends StatelessWidget {
  const FacebookIcon({super.key, this.size = 21});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/facebook.svg',
      width: size,
      height: size,
    );
  }
}
