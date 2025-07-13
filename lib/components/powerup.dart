import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PowerUp extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isUnlocked;

  const PowerUp({
    super.key,
    required this.imagePath,
    required this.title,
    this.isUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      color: Colors.white, 
      child: SvgPicture.asset(
        imagePath,
      //   colorFilter: isUnlocked
      //       ? null
      //       : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      ),
    );
  }
}
