import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class Pressable extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;

  const Pressable({
    super.key,
    this.onTap,
    required this.child,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() {
          _scale = 0.96;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },
      child: SingleMotionBuilder(
        motion: CupertinoMotion.smooth(),
        value: _scale,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
