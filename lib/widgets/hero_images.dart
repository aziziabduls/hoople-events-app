import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';
import 'package:progressive_blur/progressive_blur.dart';

class HeroImage extends StatelessWidget {
  const HeroImage({
    super.key,
    required this.prominentColor,
    required this.event,
  });

  final Color? prominentColor;
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return ProgressiveBlurWidget(
      tintColor: prominentColor ?? Colors.black.withValues(alpha: 0.5),
      linearGradientBlur: LinearGradientBlur(
        values: [0, 1],
        stops: [0.5, 0.8],
        start: Platform.isAndroid
            ? Alignment.bottomCenter
            : Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      sigma: 24.0,
      blurTextureDimensions: 128,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: Platform.isAndroid
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 0.8],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    prominentColor ?? Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              )
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    prominentColor ?? Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          color: Colors.grey,
          child: event.imageUrl.startsWith('assets/')
              ? Image.asset(
                  event.imageUrl,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(event.imageUrl),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
