import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void showBottomSheetAdaptive({
  required BuildContext context,
  required Widget child,
  NavigatorState? navigatorState,
}) {
  navigatorState ??= Navigator.of(context);

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    navigatorState.push(cupertinoRoute(child));
  } else {
    navigatorState.push(androidRoute(child));
  }
}

PageRoute cupertinoRoute(Widget child) {
  return CupertinoSheetRoute<void>(builder: (context) => child);
}

PageRoute androidRoute(Widget child) {
  return PageRouteBuilder<void>(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) => Padding(
          padding: EdgeInsets.only(top: 20),
          // ignore: deprecated_member_use
          child: PopScope(
            canPop: false,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: child,
            ),
          ),
        ),
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(curved),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
  );
}
