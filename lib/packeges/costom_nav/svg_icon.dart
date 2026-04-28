import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;

  const SvgIcon({
    super.key,
    required this.assetPath,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
    );
  }
}