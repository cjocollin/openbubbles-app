import 'package:flutter/material.dart';

class ExpressiveClipper extends CustomClipper<Path> {
  final bool isFromMe;
  final bool connectUpper;
  final bool connectLower;

  ExpressiveClipper({
    required this.isFromMe,
    required this.connectUpper,
    required this.connectLower,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;

    // Radius values
    const double sharp = 4.0;
    const double round = 18.0;

    Radius topLeft;
    Radius topRight;
    Radius bottomLeft;
    Radius bottomRight;

    if (isFromMe) {
      // Sent Message (Right Aligned)
      // Right side is always sharp (4px)
      topRight = const Radius.circular(sharp);
      bottomRight = const Radius.circular(sharp);

      // Left side is round (18px) unless connected
      topLeft = connectUpper ? const Radius.circular(sharp) : const Radius.circular(round);
      bottomLeft = connectLower ? const Radius.circular(sharp) : const Radius.circular(round);
    } else {
      // Received Message (Left Aligned)
      // Left side is always sharp (4px)
      topLeft = const Radius.circular(sharp);
      bottomLeft = const Radius.circular(sharp);

      // Right side is round (18px) unless connected
      topRight = connectUpper ? const Radius.circular(sharp) : const Radius.circular(round);
      bottomRight = connectLower ? const Radius.circular(sharp) : const Radius.circular(round);
    }

    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, width, height),
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    ));

    return path;
  }

  @override
  bool shouldReclip(covariant ExpressiveClipper oldClipper) {
    return isFromMe != oldClipper.isFromMe ||
        connectUpper != oldClipper.connectUpper ||
        connectLower != oldClipper.connectLower;
  }
}
