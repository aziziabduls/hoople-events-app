import 'package:flutter/material.dart';

class EventBannerImage extends StatelessWidget {
  final String imagePath;

  const EventBannerImage({
    super.key,
    this.imagePath = 'assets/images/padel-assets-g.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
