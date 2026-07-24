// import 'dart:convert';
// import 'dart:io';

// import 'package:figma_squircle/figma_squircle.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hoople_mobile_app/core/constants/colors.dart';
// import 'package:hoople_mobile_app/core/constants/fonts.dart';
// import 'package:hoople_mobile_app/core/constants/images.dart';
// import 'package:hoople_mobile_app/core/themes/spring_page_physics.dart';
// import 'package:hoople_mobile_app/core/utils/num_extensions.dart';
// import 'package:hoople_mobile_app/models/event_model.dart';
// import 'package:hoople_mobile_app/widgets/pressable.dart';
// import 'package:hoople_mobile_app/widgets/smooth_image.dart';
// import 'package:material_shapes/material_shapes.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late final PageController _pageController;
//   double _currentPage = 0.0;
//   List<EventModel> _events = [];

//   bool _isLoading = true;
//   // bool _isSelectedCategory = false;
//   // List<String> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(
//       viewportFraction: 0.9,
//     );
//     _pageController.addListener(() {
//       if (_pageController.hasClients) {
//         setState(() {
//           _currentPage = _pageController.page ?? 0.0;
//         });
//       }
//     });
//     _loadEvents();
//     // loadEcmptyEvents();
//   }

//   Future<void> loadEcmptyEvents() async {
//     try {
//       setState(() {
//         _events = [];
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadEvents() async {
//     try {
//       final jsonString = await rootBundle.loadString('assets/data/events.json');
//       final List<dynamic> jsonList = jsonDecode(jsonString);
//       setState(() {
//         _events = jsonList.map((e) => EventModel.fromJson(e)).toList();
//         _isLoading = false;
//       });

//       // _categories = _events.map((e) => e.category).toSet().toList();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'event music':
//         return MyColor.systemPink;
//       case 'experimental learning':
//         return MyColor.systemOrange;
//       case 'member of sport':
//         return MyColor.systemGreen;
//       case 'yoga class':
//         return MyColor.systemTeal;
//       case 'event':
//       default:
//         return MyColor.systemBlue;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: false,
//         elevation: 0.0,
//         scrolledUnderElevation: 0.0,
//         // title: Text(
//         //   'Hoople Events',
//         //   style: TextStyle(
//         //     fontFamily: MyFonts.primaryFont,
//         //     fontWeight: FontWeight.w900,
//         //     fontSize: 34,
//         //     letterSpacing: -3.0,
//         //   ),
//         // ),
//         title: Image.asset(
//           'assets/images/logo-horizontal.png',
//           scale: 26,
//         ),
//         actionsPadding: const EdgeInsets.only(right: 16),
//         actions: [
//           Visibility(
//             visible: _events.isNotEmpty,
//             child: Material(
//               color: Theme.of(context).colorScheme.primaryContainer,
//               shape: MaterialShapeBorder(
//                 shape: MaterialShapes.cookie7Sided,
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: InkWell(
//                 onTap: () {
//                   // Navigator.of(context).push(ExplorePage.route());
//                 },
//                 child: SizedBox(
//                   width: 42,
//                   height: 42,
//                   child: Icon(
//                     Icons.add_rounded,
//                     color: Theme.of(context).colorScheme.onSecondaryContainer,
//                     size: 30,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           10.gap,
//           Pressable(
//             child: InkWell(
//               onTap: () {
//                 context.push('/profile');
//               },
//               customBorder: MaterialShapeBorder(
//                 shape: MaterialShapes.cookie7Sided,
//               ),
//               child: ClipPath(
//                 clipper: ShapeBorderClipper(
//                   shape: MaterialShapeBorder(
//                     shape: MaterialShapes.pill,
//                   ),
//                 ),
//                 child: const SizedBox(
//                   width: 42,
//                   height: 42,
//                   child: SmoothImage(
//                     url: MyImages.placeholder,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _events.isEmpty
//           ? RefreshIndicator(
//               onRefresh: () async {
//                 await Future.delayed(const Duration(seconds: 1));
//                 _loadEvents();
//               },
//               child: ListView(
//                 children: [
//                   Container(
//                     color: Colors.transparent,
//                     height: MediaQuery.of(context).size.height * 0.8,
//                     width: double.infinity,
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: .min,
//                         children: [
//                           Material(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.primaryContainer,
//                             shape: MaterialShapeBorder(
//                               shape: MaterialShapes.cookie7Sided,
//                             ),
//                             clipBehavior: Clip.antiAlias,
//                             child: InkWell(
//                               onTap: () {
//                                 // Navigator.of(context).push(ExplorePage.route());
//                               },
//                               child: SizedBox(
//                                 width: 82,
//                                 height: 82,
//                                 child: Icon(
//                                   Icons.add_rounded,
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onSecondaryContainer,
//                                   size: 70,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           20.gap,
//                           Text(
//                             'No events found',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.w500,
//                               fontFamily: MyFonts.primaryFont,
//                               letterSpacing: -1,
//                             ),
//                           ),
//                           Text(
//                             'Let\'s create one now',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: MyFonts.primaryFont,
//                               letterSpacing: -1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: () async {
//                 await Future.delayed(const Duration(seconds: 1));
//                 // _loadEvents();
//                 loadEcmptyEvents();
//               },
//               child: PageView.builder(
//                 scrollDirection: Axis.vertical,
//                 controller: _pageController,
//                 itemCount: _events.length,
//                 physics: const SpringPagePhysics(),
//                 // physics: const BouncingScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   final event = _events[index];
//                   final double diff = index - _currentPage;

//                   // 3D vertical perspective transform
//                   final double scale = (1.0 - (diff.abs() * 0.08)).clamp(
//                     0.85,
//                     1.0,
//                   );
//                   final double translationY = diff * -25.0;
//                   final double rotationX = (diff * 0.12).clamp(-0.3, 0.3);
//                   final double opacity = (1.0 - (diff.abs() * 0.4)).clamp(
//                     0.5,
//                     1.0,
//                   );

//                   return Transform(
//                     transform: Matrix4.identity()
//                       ..setEntry(3, 2, 0.001) // perspective
//                       ..translate(0.0, translationY)
//                       ..scale(scale)
//                       ..rotateX(rotationX),
//                     alignment: Alignment.center,
//                     child: Opacity(
//                       opacity: opacity,
//                       child: Pressable(
//                         onTap: () {
//                           context.push('/event-detail', extra: event).then((_) {
//                             // Force update in case following status changed in details
//                             setState(() {});
//                           });
//                         },
//                         child: Container(
//                           margin: EdgeInsets.only(
//                             top: _events.indexOf(event) == 0 ? 0 : 20,
//                             left: 16,
//                             right: 16,
//                             bottom: 16,
//                           ),
//                           child: ClipSmoothRect(
//                             radius: SmoothBorderRadius(
//                               cornerRadius: 40,
//                               cornerSmoothing: 1.0,
//                             ),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 // Hero Image
//                                 Image(
//                                   image: event.imageUrl.startsWith('assets/')
//                                       ? AssetImage(event.imageUrl)
//                                             as ImageProvider
//                                       : FileImage(File(event.imageUrl)),
//                                   fit: BoxFit.cover,
//                                 ),

//                                 // Dark vignette gradient overlay for text readability
//                                 DecoratedBox(
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                       colors: [
//                                         Colors.black.withOpacity(0.0),
//                                         Colors.black.withOpacity(0.15),
//                                         Colors.black.withOpacity(0.65),
//                                       ],
//                                       stops: const [0.4, 0.7, 1.0],
//                                     ),
//                                   ),
//                                 ),

//                                 // Inside-card Pill Badges (Category & Action)
//                                 Positioned(
//                                   bottom: 24,
//                                   left: 20,
//                                   right: 20,
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       // Category Pill
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 6,
//                                         ),
//                                         margin: const EdgeInsets.only(
//                                           bottom: 12,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: _getCategoryColor(
//                                             event.category,
//                                           ).withOpacity(0.85),
//                                           borderRadius: BorderRadius.circular(
//                                             12,
//                                           ),
//                                         ),
//                                         child: Text(
//                                           event.category.toUpperCase(),
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.w900,
//                                             letterSpacing: 1.0,
//                                             fontFamily: 'sf-pro',
//                                           ),
//                                         ),
//                                       ),

//                                       Text(
//                                         event.name,
//                                         textAlign: TextAlign.center,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: 'sf-pro',
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       FittedBox(
//                                         fit: BoxFit.fitWidth,
//                                         child: Text(
//                                           event.tagline,
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                             color: Colors.white70,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w600,
//                                             fontFamily: 'sf-pro',
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 6),
//                                       // location
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           const Icon(
//                                             Icons.location_on,
//                                             color: Colors.white70,
//                                             size: 12,
//                                           ),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             event.location,
//                                             textAlign: TextAlign.center,
//                                             style: const TextStyle(
//                                               color: Colors.white70,
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w400,
//                                               fontFamily: 'sf-pro',
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }
