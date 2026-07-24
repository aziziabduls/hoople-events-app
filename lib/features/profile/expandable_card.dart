import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/widgets/expanded_card.dart';
import 'package:hoople_mobile_app/widgets/styled_back_button.dart';

const _cards = <ExpandCard>[
  ExpandCard(
    id: 'focus',
    label: 'Featured',
    title: 'Deep Focus',
    subtitle: 'The apps that kill your notifications for you.',
    body:
        'The trick behind this transition: the card you tap is measured in window coordinates, then a clone is mounted in an overlay and animated from that exact rect to fullscreen. The list zooms out behind it. Drag down to send it back to its slot: same curve, reversed, and the clone lands pixel-perfect where it came from.',
    colors: [Color(0xFF3B2F2A), Color(0xFF8A5A3B)],
  ),
  ExpandCard(
    id: 'night',
    label: 'Collection',
    title: 'Night Shift',
    subtitle: 'Six apps that work while you sleep.',
    body:
        'Nothing here is a screen or a navigator. It is one shared element: the card face widget is rendered twice, once in the list and once in the overlay, and only the rect interpolates. Corner radius, header height and body opacity all derive from a single progress value, so the motion can never desync.',
    colors: [Color(0xFF1A1D24), Color(0xFF4A5568)],
  ),
  ExpandCard(
    id: 'morning',
    label: 'How to',
    title: 'Slow Mornings',
    subtitle: 'A calmer start, one habit at a time.',
    body:
        'The dismiss is the App Store one: the pan shrinks the sheet as it slides, and past a distance or velocity threshold it releases into the close animation. Under the threshold it snaps back to fullscreen. The background list follows the same progress the whole way.',
    colors: [Color(0xFF7A4A2B), Color(0xFFD9A066)],
  ),
];

class ExpandableCard extends StatelessWidget {
  const ExpandableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(leading: StyledBackButton()),
      backgroundColor: dark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: top + 24, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '/ CARD EXPAND',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    letterSpacing: 2.4,
                    color: dark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: dark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          CardExpand(cards: _cards, topInset: top + 110),
        ],
      ),
    );
  }
}
