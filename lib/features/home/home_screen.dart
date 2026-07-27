import 'dart:convert';
import 'dart:io';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hoople_mobile_app/core/constants/colors.dart';
import 'package:hoople_mobile_app/core/constants/common.dart';
import 'package:hoople_mobile_app/core/constants/fonts.dart';
import 'package:hoople_mobile_app/core/constants/images.dart';
import 'package:hoople_mobile_app/core/themes/spring_page_physics.dart';
import 'package:hoople_mobile_app/core/utils/num_extensions.dart';
import 'package:hoople_mobile_app/features/events/detail_screen.dart';
import 'package:hoople_mobile_app/models/event_model.dart';
import 'package:hoople_mobile_app/models/experience_model.dart';
import 'package:hoople_mobile_app/widgets/pressable.dart';
import 'package:material_shapes/material_shapes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  double _currentPage = 0.0;
  List<EventModel> events = [];
  List<Experience> _experience = [];

  bool _isLoading = true;
  bool isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.9,
    );
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      }
    });
    // loadEvents();
    _loadExperience();
  }

  Future<void> loadEcmptyEvents() async {
    try {
      setState(() {
        events = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadEvents() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/events.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        events = jsonList.map((e) => EventModel.fromJson(e)).toList();
        _isLoading = false;
      });

      // _categories = events.map((e) => e.category).toSet().toList();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExperience() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/experience.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _experience = jsonList.map((e) => Experience.fromJson(e)).toList();
        _isLoading = false;
      });
      print(_experience.length);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'activity':
        return MyColor.hoopleCharcoal;
      case 'event':
      default:
        return MyColor.hooplePurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        title: Image.asset(
          isDark
              ? 'assets/images/logo-horizontal-dark.png'
              : 'assets/images/logo-horizontal.png',
          scale: 26,
        ),
        actionsPadding: const EdgeInsets.only(right: 16),
        actions: [
          Visibility(
            // visible: events.isNotEmpty,
            visible: true,
            child: Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: MaterialShapeBorder(
                shape: MaterialShapes.cookie7Sided,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  context.push<Experience>('/create-experience').then((newExp) {
                    if (newExp != null) {
                      setState(() {
                        _experience.insert(0, newExp);
                      });
                    }
                  });
                },
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.add_rounded,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          6.gap,
          Visibility(
            // visible: events.isNotEmpty,
            visible: true,
            child: Material(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              shape: MaterialShapeBorder(
                shape: MaterialShapes.cookie7Sided,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  context.push('/search', extra: _experience).then((_) {
                    setState(() {});
                  });
                },
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          10.gap,
          Pressable(
            child: InkWell(
              onTap: () {
                context.push('/profile');
              },
              customBorder: MaterialShapeBorder(
                shape: MaterialShapes.cookie7Sided,
              ),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: MaterialShapeBorder(
                    shape: MaterialShapes.pill,
                  ),
                ),
                // child: const SizedBox(
                //   width: 42,
                //   height: 42,
                //   child: SmoothImage(
                //     url: MyImages.placeholder,
                //   ),
                // ),
                child: MyImages.placeholder.contains('http')
                    ? Image.network(
                        MyImages.placeholder,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, chunk, loadingProgress) {
                          return chunk;
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            height: 42,
                            width: 42,
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                shape: MaterialShapeBorder(
                                  shape: MaterialShapes.clover8Leaf,
                                ),
                              ),
                              child: Container(
                                color: Colors.grey[300],
                                width: 42,
                                height: 42,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        MyImages.placeholder,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            height: 42,
                            width: 42,
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                shape: MaterialShapeBorder(
                                  shape: MaterialShapes.clover8Leaf,
                                ),
                              ),
                              child: Container(
                                color: Colors.grey[300],
                                width: 42,
                                height: 42,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _experience.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    _loadExperience();
                  },
                  child: ListView(
                    children: [
                      Container(
                        color: Colors.transparent,
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: double.infinity,
                        child: Center(
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              Material(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                shape: MaterialShapeBorder(
                                  shape: MaterialShapes.cookie7Sided,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.of(context).push(ExplorePage.route());
                                  },
                                  child: SizedBox(
                                    width: 82,
                                    height: 82,
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                      size: 70,
                                    ),
                                  ),
                                ),
                              ),
                              20.gap,
                              Text(
                                'No events found',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: MyFonts.primaryFont,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                'Let\'s create one now',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: MyFonts.primaryFont,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    _loadExperience();
                  },
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    itemCount: _experience.length,
                    physics: const SpringPagePhysics(),
                    itemBuilder: (context, index) {
                      // final event = events[index];
                      final experience = _experience[index];
                      final double diff = index - _currentPage;

                      // 3D vertical perspective transform
                      final double scale = (1.0 - (diff.abs() * 0.08)).clamp(
                        0.85,
                        1.0,
                      );
                      final double translationY = diff * -25.0;
                      final double rotationX = (diff * 0.12).clamp(-0.3, 0.3);
                      final double opacity = (1.0 - (diff.abs() * 0.4)).clamp(
                        0.5,
                        1.0,
                      );

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..translate(0.0, translationY)
                          ..scale(scale)
                          ..rotateX(rotationX),
                        alignment: Alignment.center,
                        child: Opacity(
                          opacity: opacity,
                          child: Pressable(
                            onTap: () async {
                              // if (isNavigating) return;
                              // setState(() {
                              //   isNavigating = true;
                              // });

                              // try {
                              //   final color = await getProminentColor(
                              //     experience,
                              //   );
                              //   if (context.mounted) {
                              //     context
                              //         .push(
                              //           '/experience-detail',
                              //           extra: {
                              //             'experience': experience,
                              //             'prominentColor': color,
                              //           },
                              //         )
                              //         .then((_) {
                              //           if (mounted) setState(() {});
                              //         });
                              //   }
                              // } finally {
                              //   if (mounted) {
                              //     setState(() {
                              //       isNavigating = false;
                              //     });
                              //   }
                              // }

                              if (isNavigating) return;
                              setState(() {
                                isNavigating = true;
                              });

                              try {
                                if (context.mounted) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        experience: experience,
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isNavigating = false;
                                  });
                                }
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                top: _experience.indexOf(experience) == 0
                                    ? 0
                                    : 20,
                                left: 16,
                                right: 16,
                                bottom: 16,
                              ),
                              child: ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                  cornerRadius: 40,
                                  cornerSmoothing: 1.0,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Hero Image
                                    Image(
                                      image:
                                          experience.basicInfo.media.banner
                                              .startsWith('assets/')
                                          ? AssetImage(
                                              experience.basicInfo.media.banner,
                                            )
                                          : FileImage(
                                                  File(
                                                    experience
                                                        .basicInfo
                                                        .media
                                                        .banner,
                                                  ),
                                                )
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.error_outline,
                                              size: 60,
                                            );
                                          },
                                    ),

                                    // Dark vignette gradient overlay for text readability
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.0),
                                            Colors.black.withOpacity(0.15),
                                            Colors.black.withOpacity(0.65),
                                          ],
                                          stops: const [0.4, 0.7, 1.0],
                                        ),
                                      ),
                                    ),

                                    // Inside-card Pill Badges (Category & Action)
                                    Positioned(
                                      bottom: 24,
                                      left: 20,
                                      right: 20,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Category Pill
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(
                                                experience.type.name
                                                    .toLowerCase(),
                                              ).withOpacity(0.885),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    MyCommonValue
                                                        .borderRadiusDefault,
                                                  ),
                                            ),
                                            child: Text(
                                              experience.type.name.capitalize(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                // letterSpacing: 1.0,
                                                fontFamily: MyFonts.opensans,
                                              ),
                                            ),
                                          ),

                                          Text(
                                            experience.basicInfo.title,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: MyFonts.primaryFont,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              experience.basicInfo.description,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: MyFonts.opensans,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // location
                                          if (experience
                                                  .location
                                                  .physical
                                                  ?.city !=
                                              null)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.white70,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),

                                                Text(
                                                  '${experience.location.physical?.city}, ${experience.location.physical?.country}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'sf-pro',
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          // if (isNavigating)
          //   Container(
          //     color: Colors.black.withOpacity(0.3),
          //     child: const Center(
          //       child: CircularProgressIndicator(),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
