import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';

class EventTagline extends StatelessWidget {
  const EventTagline({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Text(
      event.tagline,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontFamily: 'sf-pro',
      ),
    );
  }
}
