import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpandCard {
  const ExpandCard({
    required this.id,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.colors,
  });

  final String id;
  final String label;
  final String title;
  final String subtitle;
  final String body;
  final List<Color> colors;
}

const double kCardHeight = 360;
const double kCardRadius = 28;
const double kFullRadius = 55;

const Curve kEase = Cubic(0.32, 0.72, 0, 1);
const Duration kOpenDuration = Duration(milliseconds: 440);
const Duration kCloseDuration = Duration(milliseconds: 380);

class CardExpand extends StatefulWidget {
  const CardExpand({super.key, required this.cards, this.topInset = 0});

  final List<ExpandCard> cards;
  final double topInset;

  @override
  State<CardExpand> createState() => _CardExpandState();
}

class _CardExpandState extends State<CardExpand>
    with SingleTickerProviderStateMixin {
  final Map<String, GlobalKey> _keys = {};
  final GlobalKey _containerKey = GlobalKey();

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: kOpenDuration,
    reverseDuration: kCloseDuration,
  );
  late final Animation<double> _eased = CurvedAnimation(
    parent: _progress,
    curve: kEase,
    reverseCurve: kEase,
  );

  ExpandCard? _open;
  Rect _origin = Rect.zero;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _openCard(ExpandCard card) {
    final box =
        _keys[card.id]!.currentContext?.findRenderObject() as RenderBox?;
    final container =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || container == null) return;

    // rect of the tapped card, in the container's coordinate space
    final topLeft = box.localToGlobal(Offset.zero, ancestor: container);
    HapticFeedback.lightImpact();
    setState(() {
      _open = card;
      _origin = topLeft & box.size;
    });
    _progress.forward(from: 0);
  }

  Future<void> _close() async {
    HapticFeedback.lightImpact();
    await _progress.reverse();
    if (mounted) setState(() => _open = null);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = size.width - 40;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          key: _containerKey,
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _eased,
              builder: (context, child) {
                final p = _eased.value;
                return Opacity(
                  opacity: 1 - p * 0.35,
                  child: Transform.scale(scale: 1 - p * 0.05, child: child),
                );
              },
              child: ListView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: widget.topInset,
                  bottom: 48,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (final card in widget.cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: () => _openCard(card),
                        child: Opacity(
                          opacity: _open?.id == card.id ? 0 : 1,
                          child: Container(
                            key: _keys.putIfAbsent(card.id, GlobalKey.new),
                            width: cardWidth,
                            height: kCardHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kCardRadius),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x2E000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(kCardRadius),
                              child: CardFace(card: card),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_open != null)
              _ExpandedOverlay(
                card: _open!,
                origin: _origin,
                container: constraints.biggest,
                progress: _eased,
                onClose: _close,
              ),
          ],
        );
      },
    );
  }
}

class CardFace extends StatelessWidget {
  const CardFace({super.key, required this.card, this.labelPadTop = 22});

  final ExpandCard card;
  final double labelPadTop;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.colors,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, labelPadTop, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.label.toUpperCase(),
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                letterSpacing: 2.4,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            Text(
              card.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                height: 1.1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.35,
                color: Colors.white,
              ).copyWith(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedOverlay extends StatefulWidget {
  const _ExpandedOverlay({
    required this.card,
    required this.origin,
    required this.container,
    required this.progress,
    required this.onClose,
  });

  final ExpandCard card;
  final Rect origin;
  final Size container;
  final Animation<double> progress;
  final VoidCallback onClose;

  @override
  State<_ExpandedOverlay> createState() => _ExpandedOverlayState();
}

class _ExpandedOverlayState extends State<_ExpandedOverlay>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _dragY = ValueNotifier(0);
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<double>? _settleAnim;

  @override
  void dispose() {
    _settle.dispose();
    _dragY.dispose();
    super.dispose();
  }

  void _settleTo(double target, Duration duration) {
    _settleAnim?.removeListener(_onSettle);
    _settleAnim = Tween<double>(begin: _dragY.value, end: target).animate(
      CurvedAnimation(parent: _settle, curve: kEase),
    )..addListener(_onSettle);
    _settle.duration = duration;
    _settle.forward(from: 0);
  }

  void _onSettle() => _dragY.value = _settleAnim!.value;

  void _onDragUpdate(DragUpdateDetails d) {
    _settle.stop();
    _dragY.value = math.max(0, _dragY.value + d.delta.dy);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragY.value > 140 || d.velocity.pixelsPerSecond.dy > 900) {
      _settleTo(0, kCloseDuration);
      widget.onClose();
    } else {
      _settleTo(0, const Duration(milliseconds: 220));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = widget.container.width;
    final h = widget.container.height;
    final o = widget.origin;
    final faceOpen = math.min(h * 0.52, 460.0);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([widget.progress, _dragY]),
      builder: (context, _) {
        final p = widget.progress.value;
        final drag = _dragY.value;
        final dragScale = _lerp(1, 0.86, (drag / 400).clamp(0.0, 1.0));

        final left = _lerp(o.left, 0, p);
        final top = _lerp(o.top, 0, p);
        final width = _lerp(o.width, w, p);
        final height = _lerp(o.height, h, p);
        final radius = _lerp(kCardRadius, kFullRadius, p);

        final bodyP = ((p - 0.55) / 0.45).clamp(0.0, 1.0);
        final closeP = ((p - 0.7) / 0.3).clamp(0.0, 1.0);

        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: Transform.translate(
            offset: Offset(0, drag * 0.6),
            child: Transform.scale(
              scale: dragScale,
              child: GestureDetector(
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Material(
                    color: theme.colorScheme.surface,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: width,
                              height: _lerp(o.height, faceOpen, p),
                              child: CardFace(
                                card: widget.card,
                                labelPadTop: _lerp(
                                  22,
                                  media.padding.top + 14,
                                  p,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Opacity(
                                opacity: bodyP,
                                child: Transform.translate(
                                  offset: Offset(0, _lerp(24, 0, bodyP)),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      24,
                                      24,
                                      40,
                                    ),
                                    child: Text(
                                      widget.card.body,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 58,
                          right: 20,
                          child: Opacity(
                            opacity: closeP,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: closeP > 0.5 ? widget.onClose : null,
                              child: Container(
                                height: 32,
                                width: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0x40000000),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
