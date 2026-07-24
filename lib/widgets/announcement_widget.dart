import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/models/event_model.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget({
    super.key,
    required this.announcementFadeAnimation,
    required this.announcementSlideAnimation,
    required this.event,
  });

  final Animation<double> announcementFadeAnimation;
  final Animation<Offset> announcementSlideAnimation;
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: announcementFadeAnimation,
      child: SlideTransition(
        position: announcementSlideAnimation,
        child: Padding(
          padding: .only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: .only(right: 25),
                child: Text(
                  'Announcements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ),
              BubbleSpecialThree(
                text: event.announcement!,
                color: Colors.white.withValues(
                  alpha: 0.9,
                ),
                tail: true,
                isSender: true,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'sf-pro',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
