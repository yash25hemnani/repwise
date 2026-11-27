import 'package:flutter/material.dart';

// Rounded top, outlined on the top and sides only. The bottom sits on the
// screen edge, where a line just reads as a stray bar
class SheetBorder extends ShapeBorder {
  const SheetBorder({this.side = BorderSide.none, this.radius = 26});

  final BorderSide side;
  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      ),
    );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  // An open path: up the left, over the top, down the right
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final half = side.width / 2;
    final r = rect.deflate(half);
    final k = Radius.circular(radius - half);
    final path = Path()
      ..moveTo(r.left, rect.bottom)
      ..lineTo(r.left, r.top + k.x)
      ..arcToPoint(Offset(r.left + k.x, r.top), radius: k)
      ..lineTo(r.right - k.x, r.top)
      ..arcToPoint(Offset(r.right, r.top + k.x), radius: k)
      ..lineTo(r.right, rect.bottom);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      SheetBorder(side: side.scale(t), radius: radius * t);
}
