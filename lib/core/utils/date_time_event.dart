import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';
import 'package:intl/intl.dart';

class DateTimeEvent extends StatelessWidget {
  final EventModel? event;

  const DateTimeEvent({
    super.key,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final dateStr = event != null
        ? dateFormat.format(event!.startDate)
        : "Saturday, 12 June 2026";
    final timeStr = event != null
        ? "${timeFormat.format(event!.startDate)} - ${timeFormat.format(event!.endDate)} (${event!.timezone})"
        : "09:00 AM - 05:00 PM";

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.calendar_month,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'sf-pro',
              ),
            ),
            Text(
              timeStr,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'sf-pro',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
