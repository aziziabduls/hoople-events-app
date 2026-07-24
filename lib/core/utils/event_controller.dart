// event_controller.dart
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';
import 'package:hoople_mobile_app/widgets/bottom_sheets.dart';
import 'package:hoople_mobile_app/widgets/payment_sheet.dart';

class EventController {
  final EventModel event;
  final Color? prominentColor;
  final BuildContext context;

  EventController({
    required this.event,
    required this.prominentColor,
    required this.context,
  });

  static void joinEvent({
    required BuildContext context,
    required EventModel event,
    required Color? prominentColor,
    required VoidCallback onJoined,
  }) {
    if (event.isFree) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 24,
              cornerSmoothing: 0.6,
            ),
          ),
          title: const Text(
            "Join Event",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to join '${event.name}'? This event is free to join.",
            // style: const TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                // style: TextStyle(color: Colors.black38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onJoined();
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(
                //     behavior: SnackBarBehavior.floating,
                //     content: Text("Joined successfully!"),
                //   ),
                // );
                // showExpressiveSnack(
                //   context: context,
                //   message: 'Joined successfully',
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: prominentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Confirm"),
            ),
          ],
        ),
      );
    } else {
      showBottomSheetAdaptive(
        context: context,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PaymentSheet(
            event: event,
            prominentColor: prominentColor ?? Theme.of(context).primaryColor,
          ),
        ),
      );
    }
  }
}
