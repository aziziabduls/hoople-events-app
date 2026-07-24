import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/utils/date_time_event.dart';
import 'package:hoople_mobile_app/core/utils/event_controller.dart';
import 'package:hoople_mobile_app/core/utils/format_number.dart';
import 'package:hoople_mobile_app/models/event_model.dart';
import 'package:hoople_mobile_app/widgets/about_events.dart';
import 'package:hoople_mobile_app/widgets/announcement_widget.dart';
import 'package:hoople_mobile_app/widgets/bottom_sheets.dart';
import 'package:hoople_mobile_app/widgets/event_banner_image.dart';
import 'package:hoople_mobile_app/widgets/event_languages.dart';
import 'package:hoople_mobile_app/widgets/event_name_widget.dart';
import 'package:hoople_mobile_app/widgets/event_stat_column.dart';
import 'package:hoople_mobile_app/widgets/event_tagline.dart';
import 'package:hoople_mobile_app/widgets/hero_images.dart';
import 'package:hoople_mobile_app/widgets/payment_sheet.dart';
import 'package:hoople_mobile_app/widgets/stacked_albums.dart';
import 'package:hoople_mobile_app/widgets/task_event.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  Color? _prominentColor;
  late AnimationController _announcementController;
  late Animation<Offset> _announcementSlideAnimation;
  late Animation<double> _announcementFadeAnimation;
  final ScrollController _scrollController = ScrollController();
  late final imageProvider = widget.event.imageUrl.startsWith('assets/')
      ? AssetImage(widget.event.imageUrl) as ImageProvider
      : FileImage(File(widget.event.imageUrl));

  @override
  void initState() {
    super.initState();
    initAnnouncement();
    if (widget.event.announcement != null &&
        widget.event.announcement!.isNotEmpty) {
      startAnnouncement();
      hideAnnouncement();
    }
    _loadProminentColor();
  }

  void startAnnouncement() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _announcementController.forward();
      }
    });
  }

  void hideAnnouncement() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _announcementController.reverse();
      }
    });
  }

  void initAnnouncement() {
    _announcementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _announcementSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _announcementController,
            curve: Curves.easeOutCubic,
          ),
        );

    _announcementFadeAnimation = CurvedAnimation(
      parent: _announcementController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _announcementController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProminentColor() async {
    final palette = await PaletteGenerator.fromImageProvider(
      widget.event.imageUrl.startsWith('assets/')
          ? AssetImage(widget.event.imageUrl) as ImageProvider
          : FileImage(File(widget.event.imageUrl)),
      size: const Size(200, 200),
    );

    if (palette.dominantColor?.color != null) {
      _prominentColor = Color.lerp(
        palette.dominantColor?.color,
        Colors.black,
        0.5,
      );
      if (mounted) setState(() {});
    }
  }

  void onJoinPressed() {
    if (widget.event.isFree) {
      _showJoinConfirmation();
    } else {
      _showPaymentSheet();
    }
  }

  void _showJoinConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 24,
            cornerSmoothing: 0.6,
          ),
        ),
        title: const Text(
          "Join Event",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to join '${widget.event.name}'? This event is free to join.",
          // style: const TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              // style: TextStyle(color: Colors.black38),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                widget.event.isFollowing = true;
              });
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     behavior: SnackBarBehavior.floating,
              //     content: Text("Joined successfully!"),
              //   ),
              // );
              onJoinPressed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _prominentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet() {
    showBottomSheetAdaptive(
      context: context,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PaymentSheet(
          event: widget.event,
          prominentColor: _prominentColor ?? Theme.of(context).primaryColor,
        ),
        // child: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prominentColor = _prominentColor ?? theme.primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: prominentColor,
      body: AnimatedBuilder(
        animation: _scrollController,
        builder: (context, child) {
          final expandedHeight = MediaQuery.of(context).size.height * 0.7;
          final toolbarHeight = 100.0;
          final offset = _scrollController.hasClients
              ? _scrollController.offset
              : 0.0;
          final opacity = (offset / (expandedHeight - toolbarHeight)).clamp(
            0.0,
            1.0,
          );

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Parallax Header
              SliverAppBar(
                expandedHeight: expandedHeight,

                pinned: true,
                stretch: true,
                backgroundColor: prominentColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.filledTonal(
                    icon: Icon(
                      Platform.isAndroid
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Opacity(
                  opacity: opacity,
                  child: Text(
                    widget.event.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                actions: actionAppBar(context),
                flexibleSpace: eventFlexibleAppBar(context, prominentColor),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -32, 0),
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: DateTimeEvent(),
                        ),
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: EventBannerImage(),
                        ),
                        const SizedBox(height: 32),
                        StackedAlbum(event: widget.event),
                        const SizedBox(height: 32),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: TaskEvents(
                            event: widget.event,
                            prominentColor: _prominentColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: AboutEvent(event: widget.event),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: EventLanguages(event: widget.event),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FlexibleSpaceBar eventFlexibleAppBar(
    BuildContext context,
    Color prominentColor,
  ) {
    return FlexibleSpaceBar(
      stretchModes: const [
        StretchMode.zoomBackground,
        StretchMode.blurBackground,
      ],
      background: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              showImageViewer(
                context,
                imageProvider,
                swipeDismissible: true,
                useSafeArea: true,
                doubleTapZoomable: true,
                onViewerDismissed: () {
                  print("dismissed");
                },
              );
            },
            child: HeroImage(
              prominentColor: _prominentColor,
              event: widget.event,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    prominentColor.withValues(alpha: 0.8),
                    prominentColor,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.event.announcement != null &&
                      widget.event.announcement!.isNotEmpty)
                    AnnouncementWidget(
                      announcementFadeAnimation: _announcementFadeAnimation,
                      announcementSlideAnimation: _announcementSlideAnimation,
                      event: widget.event,
                    ),
                  const SizedBox(height: 12),
                  EventName(event: widget.event),
                  EventTagline(event: widget.event),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      EventStatColumn(
                        label: 'Price',
                        value: widget.event.isFree
                            ? 'Free'
                            : formatNumber(
                                widget.event.price.toInt(),
                              ),
                      ),
                      EventStatColumn(
                        label: 'Participants',
                        value: widget.event.participantCapacity.toString(),
                      ),
                      EventStatColumn(
                        label: 'Location',
                        value: widget.event.locationDetails['city'],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> actionAppBar(BuildContext context) {
    return [
      if (!widget.event.isFollowing)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              EventController.joinEvent(
                context: context,
                event: widget.event,
                prominentColor: _prominentColor,
                onJoined: () {
                  setState(() {
                    widget.event.isFollowing = true;
                  });
                },
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text("Join"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
      if (widget.event.isFollowing)
        Padding(
          padding: EdgeInsets.zero,
          child: IconButton.filledTonal(
            icon: const Icon(Icons.qr_code_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black26,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // show qr view in bottom sheet with name event

              showQr(context);
            },
          ),
        ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton.filledTonal(
          icon: const Icon(Icons.share_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black26,
            foregroundColor: Colors.white,
          ),
          onPressed: () {},
        ),
      ),
    ];
  }

  void showQr(BuildContext context) {
    return showBottomSheetAdaptive(
      context: context,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom,
        ),
        child: Material(
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor,
          borderRadius: SmoothBorderRadius.only(
            topLeft: const SmoothRadius(
              cornerRadius: 32,
              cornerSmoothing: 0.6,
            ),
            topRight: const SmoothRadius(
              cornerRadius: 32,
              cornerSmoothing: 0.6,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // add close button
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: .min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.event.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 26),
                    QrImageView(
                      data: widget.event.name.toString(),
                      version: QrVersions.auto,
                      size: 320,
                      gapless: false,
                    ),
                    // const SizedBox(height: 16),
                    Spacer(),
                    // use this qr to access event and merchandise
                    const Text(
                      "Use this QR code to access event and merchandise",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
