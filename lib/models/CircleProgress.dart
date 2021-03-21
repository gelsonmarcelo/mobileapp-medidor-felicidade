import 'package:flutter/material.dart';
import 'dart:math';

class CircleProgress extends CustomPainter {
  double currentProgress;

  CircleProgress(this.currentProgress);

  @override
  void paint(Canvas canvas, Size size) {
    //this is base circle
    Paint outerCircle = Paint()
      ..strokeWidth = 10
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    Paint completeArc;

    if (currentProgress < 20) {
      completeArc = Paint()
        ..strokeWidth = 10
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else if (currentProgress < 40) {
      completeArc = Paint()
        ..strokeWidth = 10
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else if (currentProgress < 60) {
      completeArc = Paint()
        ..strokeWidth = 10
        ..color = Colors.blueAccent[700]
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else if (currentProgress < 80) {
      completeArc = Paint()
        ..strokeWidth = 10
        ..color = Colors.lightBlue
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else {
      completeArc = Paint()
        ..strokeWidth = 10
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    }

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 10;

    canvas.drawCircle(
        center, radius, outerCircle); // this draws main outer circle

    double angle = 2 * pi * (currentProgress / 100);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
