import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';

class EventName extends StatelessWidget {
  const EventName({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Text(
      event.name,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'sf-pro',
      ),
    );
  }
}
