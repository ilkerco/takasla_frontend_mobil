import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final Container? child;
  const AnimatedBackground({Key? key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        //width: child!.constraints!.maxWidth,
        //height: child!.constraints!.maxHeight,

        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut, //Curves.easeInExpo, //Curves.easeOut,
        child:
            child /*SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), child: child)*/
        );
  }
}
