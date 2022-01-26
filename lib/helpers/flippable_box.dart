import 'package:flutter/material.dart';
import 'package:takasla/helpers/rotation_y.dart';

import 'animated_background.dart';

class FlippableBox extends StatelessWidget {
  final Container? front;
  final Container? back;

  final bool isFlipped;

  const FlippableBox({Key? key, this.isFlipped = false, this.front, this.back})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut, //Curves.easeInExpo, //Curves.easeOut,
      tween: Tween(begin: 0.0, end: isFlipped ? 180.0 : 0.0),
      builder: (context, value, child) {
        var content = double.parse(value.toString()) >= 90 ? back : front;
        return RotationY(
          rotationY: double.parse(value.toString()),
          child: RotationY(
              rotationY: double.parse(value.toString()) > 90 ? 180 : 0,
              child: AnimatedBackground(child: content)),
        );
      },
    );
  }
}
