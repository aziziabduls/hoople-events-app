import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hoople_mobile_app/core/constants/colors.dart';
import 'package:hoople_mobile_app/core/utils/num_extensions.dart';
import 'package:hoople_mobile_app/models/onboarding_event_model.dart';
import 'package:hoople_mobile_app/widgets/hoople_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // Infinite scroll initial index
  static const int _initialPage = 1000;

  late final PageController _pageController;
  double _currentPage = _initialPage.toDouble();
  Timer? _autoScrollTimer;

  List<OnboardingEventModel> _onboardingEvents = [];
  bool _isLoading = true;

  // Entrance Animations
  late final AnimationController _entranceController;
  late final Animation<double> _carouselOpacity;
  late final Animation<double> _carouselScale;
  late final Animation<double> _dotsOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineSlide;

  @override
  void initState() {
    super.initState();
    // viewportFraction 0.70 allows seeing the side cards beautifully
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.70,
    );
    _pageController.addListener(_onPageScroll);

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _carouselOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _carouselScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final jsonString = await DefaultAssetBundle.of(context).loadString(
        'assets/data/onboarding_data.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _onboardingEvents = jsonList
            .map((e) => OnboardingEventModel.fromJson(e))
            .toList();
        _isLoading = false;
      });
      _entranceController.forward();
      _startAutoScroll();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _entranceController.forward();
      _startAutoScroll();
    }
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      setState(() {
        _currentPage = _pageController.page ?? _initialPage.toDouble();
      });
    }
  }

  void _startAutoScroll() {
    _stopAutoScroll();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage =
            (_pageController.page ?? _initialPage.toDouble()).round() + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Current active index modulo slide count
    final activeIndex = _onboardingEvents.isNotEmpty
        ? (_currentPage.round() % _onboardingEvents.length)
        : 0;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Color(0xFF7E57C2),
                MyColor.scavBlue,
                Color(0xFF9575CD),
                Color(0xFFB39DDB),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 14),
                        // Carousel Container
                        Expanded(
                          flex: 14,
                          child: Opacity(
                            opacity: _carouselOpacity.value,
                            child: Transform.scale(
                              scale: _carouselScale.value,
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification is UserScrollNotification) {
                                    if (notification.direction ==
                                        ScrollDirection.idle) {
                                      // User stopped scrolling, restart timer
                                      _startAutoScroll();
                                    } else {
                                      // User is dragging, pause timer
                                      _stopAutoScroll();
                                    }
                                  }
                                  return false;
                                },
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemBuilder: (context, index) {
                                    return _buildCarouselItem(index);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Page Indicator Dots
                        Opacity(
                          opacity: _dotsOpacity.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_onboardingEvents.length, (
                              dotIndex,
                            ) {
                              final isSelected = activeIndex == dotIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutBack,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: isSelected ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Info Column and Text
                        Expanded(
                          flex: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title
                                Opacity(
                                  opacity: _titleOpacity.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _titleSlide.value),
                                    child: const Text(
                                      'No More Boring Events',
                                      maxLines: 2,

                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        letterSpacing: -1.5,
                                        fontWeight: FontWeight.w800,
                                        // fontFamily: 'sf-pro',
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Tagline
                                Opacity(
                                  opacity: _taglineOpacity.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _taglineSlide.value),
                                    child: const Text(
                                      "Create, manage, and scale events, learning activities and communities in one seamless platform.",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        letterSpacing: -1,
                                        // fontFamily: 'sf-pro',
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                HoopleButton(
                                  onTap: () {
                                    context.go('/home');
                                  },
                                  text: "Get Started",
                                ),
                                const SizedBox(height: 36),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(int index) {
    if (_onboardingEvents.isEmpty) return const SizedBox.shrink();
    final event = _onboardingEvents[index % _onboardingEvents.length];

    // Calculate the distance from center page
    final double diff = index - _currentPage;

    // Scale: center card is 1.0, side cards shrink
    final double scale = (1.0 - (diff.abs() * 0.12)).clamp(0.85, 1.0);

    // Rotation: tilt outwards
    final double rotation = (diff * 0.05).clamp(-0.15, 0.15);

    // Horizontal overlapping translation
    final double translationX = -diff * 22.0;

    // Vertical alignment shift
    final double translationY = diff.abs() * 10.0;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..translate(translationX, translationY)
        ..scale(scale)
        ..rotateZ(rotation),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 40,
            cornerSmoothing: 1.0,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image(
                image: event.imageUrl.startsWith('assets/')
                    ? AssetImage(event.imageUrl) as ImageProvider
                    : FileImage(File(event.imageUrl)),
                fit: BoxFit.cover,
              ),

              // Dark vignette gradient overlay for text readability
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // event/activity name
              Positioned(
                bottom: 15,
                left: 10,
                right: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small Category Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              // letterSpacing: 2.0,
                              // fontFamily: 'sf-pro',
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              event.tagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withAlpha(2000),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                // fontFamily: 'sf-pro',
                              ),
                            ),
                          ),
                          6.gap,
                          // location
                          Text(
                            event.location,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              // fontFamily: 'sf-pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fallback procedural leaves stack when offline or load fails
  Widget buildFallbackFoliage() {
    return Stack(
      children: [
        Positioned(
          right: -30,
          top: 0,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.green[800]!.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 30,
          top: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.lightGreen[700]!.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -10,
          top: 80,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green[900]!.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
