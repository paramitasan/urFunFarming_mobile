import 'package:flutter_svg/flutter_svg.dart';
// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// One of the Figma icons in assets/icons/, tinted with [color].
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.asset, {super.key, required this.size, this.color});

  /// Path such as 'assets/icons/nav_home.svg'.
  final String asset;
  final double size;

  /// Defaults to the surrounding [IconTheme] colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter:
          tint == null ? null : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
