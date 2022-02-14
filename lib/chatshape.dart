import 'package:flutter/rendering.dart';

class ChatShapeRight extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();
    path.lineTo(width, 0);
    path.lineTo(width - 10, ((height * 0.2) <= 10) ? height * 0.2 : 10);
    path.lineTo(width - 10, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ChatShapeLeft extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(10, height);
    path.lineTo(10, ((height * 0.2) <= 10) ? height * 0.2 : 10);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
