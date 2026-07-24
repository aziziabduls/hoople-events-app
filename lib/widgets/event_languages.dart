import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';

class EventLanguages extends StatelessWidget {
  const EventLanguages({
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
          "Languages",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'sf-pro',
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: event.availableLanguages.map((lang) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                lang,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
