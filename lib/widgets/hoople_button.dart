import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoople_mobile_app/core/constants/common.dart';
import 'package:hoople_mobile_app/widgets/pressable.dart';

class HoopleButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final bool isDisabled;
  final bool isTransparent;
  final TextStyle? textStyle;
  final bool showShadow;

  const HoopleButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isDisabled = false,
    this.isTransparent = false,
    this.showShadow = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (!isDisabled) {
          onTap();
        }
      },
      child: Container(
        width: double.infinity,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[300]
              : isTransparent
              ? Colors.transparent
              : Colors.white,
          borderRadius: BorderRadius.circular(
            MyCommonValue.borderRadiusDefault,
          ),
          boxShadow: isTransparent
              ? []
              : showShadow
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(
                      0.2,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style:
              textStyle ??
              TextStyle(
                color: isDisabled
                    ? Colors.grey[600]
                    : isTransparent
                    ? Colors.white
                    : Colors.purple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.7,
                // fontFamily: 'sf-pro',
              ),
        ),
      ),
    );
  }
}
