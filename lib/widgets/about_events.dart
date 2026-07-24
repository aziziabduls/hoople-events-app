import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';

class AboutEvent extends StatelessWidget {
  const AboutEvent({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About Event",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'sf-pro',
          ),
        ),
        SizedBox(height: 0),
        Text(
          event.description,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
            fontFamily: 'sf-pro',
          ),
        ),
      ],
    );
  }
}
