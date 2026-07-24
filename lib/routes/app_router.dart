import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoople_mobile_app/features/events/event_detail_screen.dart';
import 'package:hoople_mobile_app/features/home/home_screen.dart';
import 'package:hoople_mobile_app/features/media/media_detail_screen.dart';
import 'package:hoople_mobile_app/features/onboarding/onboarding_screen.dart';
import 'package:hoople_mobile_app/features/profile/profile_screen.dart';
import 'package:hoople_mobile_app/features/settings/setting_screen.dart';
import 'package:hoople_mobile_app/features/experiences/experience_detail_screen.dart';
import 'package:hoople_mobile_app/features/experiences/experience_form_screen.dart';
import 'package:hoople_mobile_app/features/search/search_screen.dart';
import 'package:hoople_mobile_app/models/event_model.dart';
import 'package:hoople_mobile_app/models/experience_model.dart';
import 'package:hoople_mobile_app/models/post_model.dart';
import 'package:hoople_mobile_app/models/user_model.dart';
import 'package:hoople_mobile_app/widgets/result_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Onboarding screen route
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Home screen route
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Profile screen route
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // Settings screen route
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingScreen(),
    ),

    // Event detail screen route
    GoRoute(
      path: '/event-detail',
      builder: (context, state) {
        final event = state.extra as EventModel;
        return EventDetailScreen(event: event);
      },
    ),

    // Experience detail screen route
    GoRoute(
      path: '/experience-detail',
      builder: (context, state) {
        final experience = state.extra as Experience;
        return ExperienceDetailScreen(experience: experience);
      },
    ),

    // Create experience screen route
    GoRoute(
      path: '/create-experience',
      builder: (context, state) => const ExperienceFormScreen(),
    ),

    // Search screen route
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final experiences = state.extra as List<Experience>;
        return SearchScreen(experiences: experiences);
      },
    ),

    // Media detail screen route
    GoRoute(
      path: '/media-detail',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return MediaDetailScreen(
          initialIndex: args['initialIndex'] as int,
          posts: (args['posts'] as List<PostModel>?) ?? const [],
          user: args['user'] as UserModel,
        );
      },
    ),

    // Result screen route
    GoRoute(
      path: '/result',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const ResultScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ).drive(
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ),
                  ),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
