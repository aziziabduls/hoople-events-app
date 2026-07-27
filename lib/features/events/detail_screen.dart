import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoople_mobile_app/core/constants/colors.dart';
import 'package:hoople_mobile_app/core/constants/fonts.dart';
import 'package:hoople_mobile_app/core/constants/images.dart';
import 'package:hoople_mobile_app/core/constants/paddings.dart';
import 'package:hoople_mobile_app/core/utils/format_number.dart';
import 'package:hoople_mobile_app/core/utils/num_extensions.dart';
import 'package:hoople_mobile_app/models/experience_model.dart';
import 'package:hoople_mobile_app/widgets/bottom_sheets.dart';
import 'package:hoople_mobile_app/widgets/event_stat_column.dart';
import 'package:hoople_mobile_app/widgets/experience_payment_sheet.dart';
import 'package:hoople_mobile_app/widgets/pressable.dart';
import 'package:hoople_mobile_app/widgets/styled_back_button.dart';
import 'package:intl/intl.dart';
import 'package:motor/motor.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final Experience experience;
  final bool isPreview;

  const DetailScreen({
    super.key,
    required this.experience,
    this.isPreview = false,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Color _backgroundColor = MyColor.charcoal;
  Color _textColor = Colors.white;

  Color get _prominentColor => _backgroundColor;
  late final ImageProvider _imageProvider;
  DateTime? _selectedDate;
  late final PageController _pageController;
  late DateTime _initialMonth;
  late DateTime _currentMonth;
  double _appBarOpacity = 0.0;
  final ScrollController _scrollController = ScrollController();
  bool entered = false;
  bool entered1 = false;
  bool entered2 = false;
  bool entered3 = false;
  bool entered4 = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _loadColorsForIOS();
    } else {
      _loadColorsForAndroid();
    }

    _initialMonth = DateTime.now();
    _currentMonth = _initialMonth;
    _pageController = PageController(initialPage: 500);

    _scrollController.addListener(() {
      final offset = _scrollController.hasClients
          ? _scrollController.offset
          : 0.0;
      final double threshold = MediaQuery.of(context).size.width * 0.5;
      if (offset > threshold) {
        setState(() {
          _appBarOpacity = 1.0;
        });
      } else {
        setState(() {
          _appBarOpacity = (offset / threshold).clamp(0.0, 1.0);
        });
      }
    });
  }

  void _startEntranceAnimations() {
    if (!mounted) return;
    setState(() {
      entered = true;
    });
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) setState(() => entered1 = true);
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => entered2 = true);
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => entered3 = true);
    });
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) setState(() => entered4 = true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadColorsForAndroid() async {
    try {
      final banner = widget.experience.basicInfo.media.banner;
      if (banner.startsWith('http')) {
        _imageProvider = CachedNetworkImageProvider(banner);
      } else if (banner.startsWith('assets/')) {
        _imageProvider = AssetImage(banner);
      } else {
        _imageProvider = FileImage(File(banner));
      }
      _backgroundColor = MyColor.charcoal;
      _textColor = Colors.white;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _startEntranceAnimations();
    }
  }

  Future<void> _loadColorsForIOS() async {
    try {
      final banner = widget.experience.basicInfo.media.banner;
      if (banner.startsWith('http')) {
        _imageProvider = CachedNetworkImageProvider(banner);
      } else if (banner.startsWith('assets/')) {
        _imageProvider = AssetImage(banner);
      } else {
        _imageProvider = FileImage(File(banner));
      }

      final palette = await PaletteGenerator.fromImageProvider(
        _imageProvider,
        size: const Size(200, 200),
      );

      if (palette.dominantColor?.color != null) {
        final bgColor = Color.lerp(
          palette.dominantColor?.color,
          Colors.black,
          0.5,
        )!;

        // Reversed (inverted) color from background color
        final invertedColor = Color.fromARGB(
          255,
          255 - bgColor.red,
          255 - bgColor.green,
          255 - bgColor.blue,
        );

        // Make sure it contrasts with the background color
        final bgLuminance = bgColor.computeLuminance();
        final invLuminance = invertedColor.computeLuminance();

        final Color textColor;
        if ((bgLuminance - invLuminance).abs() < 0.3) {
          textColor = bgLuminance > 0.5 ? Colors.black87 : Colors.white;
        } else {
          textColor = invertedColor;
        }

        if (mounted) {
          setState(() {
            _backgroundColor = bgColor;
            _textColor = textColor;
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting colors from image: $e');
    } finally {
      _startEntranceAnimations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
        // Adjust icons brightness for light/dark theme readability
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10.0 * _appBarOpacity,
                sigmaY: 10.0 * _appBarOpacity,
              ),
              child: Container(
                color: _backgroundColor.withOpacity(_appBarOpacity),
              ),
            ),
          ),
          scrolledUnderElevation: 0,
          elevation: 0,
          foregroundColor: _textColor,
          leading: StyledBackButton(),
          title: Opacity(
            opacity: _appBarOpacity,
            child: Text(
              widget.experience.basicInfo.title,
              style: TextStyle(
                color: _textColor,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Blurred and darkened banner image background
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.5),
                    BlendMode.darken,
                  ),
                  child:
                      widget.experience.basicInfo.media.banner.startsWith(
                        'http',
                      )
                      ? CachedNetworkImage(
                          imageUrl: widget.experience.basicInfo.media.banner,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Image.asset(
                          widget.experience.basicInfo.media.banner,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
            ),

            ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                120.gap,
                Pressable(
                  child: Align(
                    alignment: .center,
                    child: SingleMotionBuilder(
                      motion:
                          const MaterialSpringMotion.expressiveSpatialSlow(),
                      value: entered ? 1.0 : 0.8,
                      builder: (context, t, child) {
                        final double tc = t.clamp(0.6, 1.0);
                        return Opacity(
                          opacity: tc,
                          child: Transform.scale(
                            scale: 0.8 + 0.2 * t,
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          showImageViewer(
                            context,
                            _imageProvider,
                            swipeDismissible: true,
                            useSafeArea: true,
                            doubleTapZoomable: true,
                          );
                        },
                        child: Container(
                          decoration: ShapeDecoration(
                            shadows: const [
                              BoxShadow(
                                color: Color(0x2E000000),
                                blurRadius: 18,
                                spreadRadius: 1,
                                offset: Offset(0, 10),
                              ),
                            ],
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 40,
                                cornerSmoothing: 1.0,
                              ),
                            ),
                          ),
                          child:
                              widget.experience.basicInfo.media.banner
                                  .startsWith(
                                    'http',
                                  )
                              ? ClipSmoothRect(
                                  radius: SmoothBorderRadius(
                                    cornerRadius: 40,
                                    cornerSmoothing: 1.0,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: widget
                                        .experience
                                        .basicInfo
                                        .media
                                        .banner,
                                    width: 300,
                                    height: 400,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipSmoothRect(
                                  radius: SmoothBorderRadius(
                                    cornerRadius: 40,
                                    cornerSmoothing: 1.0,
                                  ),
                                  child: Image.asset(
                                    widget.experience.basicInfo.media.banner,
                                    width: 300,
                                    height: 400,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                SingleMotionBuilder(
                  motion: const MaterialSpringMotion.expressiveSpatialSlow(),
                  value: entered1 ? 1.0 : 0.0,
                  builder: (context, t, child) {
                    final double tc = t.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: tc,
                      child: Transform.translate(
                        offset: Offset(0.0, 20.0 * (1.0 - t)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      28.gap,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MySize.bodyPadding,
                        ),
                        child: Text(
                          widget.experience.basicInfo.title,
                          textAlign: .center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                      ),
                      10.gap,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MySize.bodyPadding,
                        ),
                        child: Text(
                          widget.experience.basicInfo.description,
                          textAlign: .center,
                          style: TextStyle(
                            fontSize: 16,
                            color: _textColor.withValues(alpha: .8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SingleMotionBuilder(
                  motion: const MaterialSpringMotion.expressiveSpatialSlow(),
                  value: entered2 ? 1.0 : 0.0,
                  builder: (context, t, child) {
                    final double tc = t.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: tc,
                      child: Transform.translate(
                        offset: Offset(0.0, 20.0 * (1.0 - t)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(MySize.bodyPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        EventStatColumn(
                          label: 'Price',
                          textColor: _textColor,
                          value: _getPriceDisplay(),
                        ),
                        EventStatColumn(
                          label: 'Capacity',
                          textColor: _textColor,
                          value: formatNumber(_calculateTotalQuota()),
                        ),
                        EventStatColumn(
                          label: 'Location',
                          textColor: _textColor,
                          value: widget.experience.location.mode == 'virtual'
                              ? 'Virtual'
                              : (widget.experience.location.physical?.city ??
                                    'TBD'),
                        ),
                      ],
                    ),
                  ),
                ),

                SingleMotionBuilder(
                  motion: const MaterialSpringMotion.expressiveSpatialSlow(),
                  value: entered3 ? 1.0 : 0.0,
                  builder: (context, t, child) {
                    final double tc = t.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: tc,
                      child: Transform.translate(
                        offset: Offset(0.0, 20.0 * (1.0 - t)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Date / Recurrence Info
                      _buildDateTimeSection(),

                      const SizedBox(height: 32),
                      if (widget.experience.location.mode == 'offline' &&
                          widget.experience.location.physical?.coordinates !=
                              null) ...[
                        _buildLocationMapSection(),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),

                SingleMotionBuilder(
                  motion: const MaterialSpringMotion.expressiveSpatialSlow(),
                  value: entered4 ? 1.0 : 0.0,
                  builder: (context, t, child) {
                    final double tc = t.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: tc,
                      child: Transform.translate(
                        offset: Offset(0.0, 20.0 * (1.0 - t)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Agenda Timeline
                      if (widget.experience.details.agenda.isNotEmpty) ...[
                        _buildAgendaSection(),
                        const SizedBox(height: 20),
                      ],
                      // Tickets / Sessions Selector Title
                      _buildTicketsSection(_prominentColor),
                      const SizedBox(height: 20),
                      // About / Description
                      _buildAboutSection(),
                    ],
                  ),
                ),

                SizedBox(height: widget.isPreview ? 160 : 120),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsSection(Color prominentColor) {
    final items = widget.experience.items;
    final isSession = widget.experience.type == ExperienceType.activity;
    final hasSchedules = items.any((item) => item.schedule != null);

    final recurrence = widget.experience.details.recurrence;
    final filteredItems = _selectedDate == null
        ? items
        : items.where(
            (item) {
              if (item.schedule == null) return false;
              final wallClock = _toWallClock(item.schedule!.startAt);
              if (recurrence != null && recurrence.day.isNotEmpty) {
                return wallClock.weekday == _selectedDate!.weekday;
              }
              return wallClock.year == _selectedDate!.year &&
                  wallClock.month == _selectedDate!.month &&
                  wallClock.day == _selectedDate!.day;
            },
          ).toList();

    return Padding(
      padding: const EdgeInsets.all(MySize.bodyPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSession ? "Available Sessions" : "Tickets",
            textAlign: .start,
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: MyFonts.primaryFont,
            ),
          ),
          const SizedBox(height: 16),
          if (hasSchedules) ...[
            _buildCalendar(prominentColor),
            const SizedBox(height: 24),
          ],
          if (filteredItems.isEmpty)
            Center(
              child: Column(
                children: [
                  Text(
                    "No sessions/tickets currently available.",
                    textAlign: .center,
                    style: TextStyle(
                      color: _textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _backgroundColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _textColor.withValues(alpha: .4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.description != null &&
                                item.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.description!,
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],

                            6.gap,
                            if (item.schedule != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: _textColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'h:mm a',
                                    ).format(
                                      _toWallClock(item.schedule!.startAt),
                                    ),
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'to',
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'h:mm a',
                                    ).format(
                                      _toWallClock(item.schedule!.endAt),
                                    ),
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            6.gap,

                            // slots left section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _backgroundColor.withValues(
                                      alpha: .4,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _textColor.withValues(alpha: .4),
                                    ),
                                  ),
                                  child: Text(
                                    'Slots: ${item.available}/${item.quota}',
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (item.schedule != null) ...[
                                  8.gap,
                                  Icon(
                                    Icons.timelapse_rounded,
                                    size: 14,
                                    color: _textColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    () {
                                      final diff = item.schedule!.endAt
                                          .difference(
                                            item.schedule!.startAt,
                                          );
                                      final hours = diff.inHours;
                                      final minutes = diff.inMinutes % 60;
                                      if (hours > 0 && minutes > 0) {
                                        return '$hours hr${hours > 1 ? 's' : ''} $minutes min${minutes > 1 ? 's' : ''}';
                                      } else if (hours > 0) {
                                        return '$hours hr${hours > 1 ? 's' : ''}';
                                      } else {
                                        return '$minutes min${minutes > 1 ? 's' : ''}';
                                      }
                                    }(),
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.price == 0
                                ? "Free"
                                : "Rp ${NumberFormat('#,###').format(item.price)}",
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: widget.isPreview
                                ? null
                                : () => _onTicketSelected(item, prominentColor),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _textColor,
                              foregroundColor: _backgroundColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: _textColor),
                              ),
                            ),
                            child: Text(
                              "Select",
                              style: TextStyle(
                                fontSize: 12,
                                color: _backgroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAgendaSection() {
    final agenda = widget.experience.details.agenda;
    if (agenda.isEmpty) return const SizedBox.shrink();

    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MySize.bodyPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Agenda",
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: MyFonts.primaryFont,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: agenda.length,
            itemBuilder: (context, index) {
              final item = agenda[index];
              final timeFormat = DateFormat('HH:mm');
              final dayFormat = DateFormat('EEE, MMM d');
              final timeStr =
                  '${timeFormat.format(item.startAt)} - ${timeFormat.format(item.endAt)}';
              final dayStr = dayFormat.format(item.startAt);

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Time Column
                    SizedBox(
                      width: 95,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'sf-pro',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayStr,
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Timeline Node (Line & Dot)
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 2,
                            color: _textColor.withOpacity(0.12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Content Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: MyFonts.primaryFont,
                              ),
                            ),
                            if (item.speaker.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    size: 14,
                                    color: _textColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.speaker,
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation(ExperienceItem item, Color prominentColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Confirm Booking",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to register for '${item.name}'? This option is free.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (item.available > 0) {
                  item.available--;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Registered successfully!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: prominentColor,
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

  void _showPaymentSheet(ExperienceItem item, Color prominentColor) {
    showBottomSheetAdaptive(
      context: context,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ExperiencePaymentSheet(
          experience: widget.experience,
          ticket: item,
          prominentColor: prominentColor,
          onPaymentSuccess: () {
            setState(() {
              if (item.available > 0) {
                item.available--;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment successful! Registered successfully."),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  void _onTicketSelected(ExperienceItem item, Color prominentColor) {
    if (item.available <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This option is sold out!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (item.price == 0) {
      _showBookingConfirmation(item, prominentColor);
    } else {
      _showPaymentSheet(item, prominentColor);
    }
  }

  DateTime _toWallClock(DateTime dt) {
    return dt.toUtc().add(const Duration(hours: 7));
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  DateTime _getMonthForIndex(int index) {
    final monthsDiff = index - 500;
    return DateTime(_initialMonth.year, _initialMonth.month + monthsDiff, 1);
  }

  Widget _buildCalendar(Color prominentColor) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _textColor.withValues(
            alpha: .4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: TextStyle(
                  color: _textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_selectedDate != null) ...[
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Clear Filter",
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: _textColor),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: _textColor,
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day.substring(0, 1),
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 290,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentMonth = _getMonthForIndex(index);
                });
              },
              itemBuilder: (context, pageIndex) {
                final monthDate = _getMonthForIndex(pageIndex);
                return _buildMonthGrid(monthDate, prominentColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(DateTime monthDate, Color prominentColor) {
    final year = monthDate.year;
    final month = monthDate.month;
    final daysInMonth = _getDaysInMonth(year, month);
    final firstDayOffset =
        DateTime(year, month, 1).weekday - 1; // 0 for Mon, 6 for Sun

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: firstDayOffset + daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          return const SizedBox.shrink();
        }
        final day = index - firstDayOffset + 1;
        final date = DateTime(year, month, day);
        final isSelected =
            _selectedDate != null &&
            _selectedDate!.year == date.year &&
            _selectedDate!.month == date.month &&
            _selectedDate!.day == date.day;

        final recurrence = widget.experience.details.recurrence;
        final dayHasSessions = () {
          if (recurrence != null && recurrence.day.isNotEmpty) {
            return recurrence.day.contains(date.weekday);
          }
          return widget.experience.items.any(
            (item) {
              if (item.schedule == null) return false;
              final wallClock = _toWallClock(item.schedule!.startAt);
              return wallClock.year == date.year &&
                  wallClock.month == date.month &&
                  wallClock.day == date.day;
            },
          );
        }();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDate = null;
              } else {
                _selectedDate = date;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? _textColor.withValues(alpha: 0.1)
                  : (dayHasSessions
                        ? _textColor.withValues(alpha: 0.1)
                        : Colors.transparent),
              border: isSelected
                  ? Border.all(color: _textColor, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected
                      ? _textColor
                      : (dayHasSessions
                            ? _textColor
                            : _textColor.withValues(alpha: 0.5)),
                  fontWeight: (isSelected || dayHasSessions)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniMap() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _openMapUrl,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  MyImages.map,
                  fit: BoxFit.cover,
                  color: Colors.grey.withValues(alpha: 0.5),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              const Center(
                child: MapPulsePin(prominentColor: Colors.redAccent),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Platform.isIOS
                            ? Icons.map_rounded
                            : Icons.directions_rounded,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Open in Maps",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMapUrl() async {
    final location = widget.experience.location.physical;
    if (location == null) return;

    final lat = location.coordinates.latitude;
    final lng = location.coordinates.longitude;

    final url = Platform.isIOS
        ? 'https://maps.apple.com/?q=$lat,$lng'
        : 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch maps: $e');
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('channel-error') ||
                      e.toString().contains('MissingPluginException')
                  ? "A native plugin (url_launcher) was added. Please stop and rebuild/restart the app."
                  : "Could not open map: ${e.toString()}",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildLocationMapSection() {
    final physical = widget.experience.location.physical!;
    // final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MySize.bodyPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Location / Venue",
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: MyFonts.primaryFont,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${physical.venue} • ${physical.address}, ${physical.city}, ${physical.country}",
            textAlign: .center,
            style: TextStyle(
              color: _textColor,
              fontSize: 14,
              fontFamily: MyFonts.opensans,
            ),
          ),
          const SizedBox(height: 16),
          _buildMiniMap(),
        ],
      ),
    );
  }

  String _getPriceDisplay() {
    if (widget.experience.items.isEmpty) return 'Free';
    final prices = widget.experience.items.map((i) => i.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    if (minPrice == 0) return 'Free';
    return formatNumber(minPrice);
  }

  int _calculateTotalQuota() {
    return widget.experience.items.fold(0, (sum, item) => sum + item.quota);
  }

  Widget _buildDateTimeSection() {
    final experience = widget.experience;
    final isEvent = experience.type == ExperienceType.event;

    IconData icon = Icons.calendar_month_rounded;
    String primaryText = "";
    String secondaryText = "";

    if (isEvent && experience.details.schedule != null) {
      final schedule = experience.details.schedule!;
      final dateFormat = DateFormat('EEEE, d MMMM yyyy');
      final timeFormat = DateFormat('hh:mm a');

      primaryText = schedule.startDate != null
          ? dateFormat.format(schedule.startDate!)
          : "TBD Date";

      if (schedule.startDate != null && schedule.endDate != null) {
        primaryText =
            schedule.startDate!.day == schedule.endDate!.day &&
                schedule.startDate!.month == schedule.endDate!.month &&
                schedule.startDate!.year == schedule.endDate!.year
            ? dateFormat.format(schedule.startDate!)
            : "${DateFormat('d MMM').format(schedule.startDate!)} - ${dateFormat.format(schedule.endDate!)}";

        secondaryText =
            "${timeFormat.format(schedule.startDate!)} - ${timeFormat.format(schedule.endDate!)} (${schedule.timezone})";
      } else {
        secondaryText = schedule.timezone;
      }
    } else {
      // Activity
      icon = Icons.local_activity;
      final rec = experience.details.recurrence?.rule;
      if (rec != null) {
        if (rec.contains("BYDAY=MO,WE")) {
          primaryText = "Every Monday & Wednesday";
        } else if (rec.contains("BYDAY=SA")) {
          primaryText = "Every Saturday";
        } else {
          primaryText = "Recurring Schedule";
        }
      } else {
        primaryText = "Flexible Schedule";
      }

      if (experience.details.instructor != null) {
        secondaryText = "Led by ${experience.details.instructor}";
      } else {
        secondaryText = "Self-guided Activity";
      }
    }

    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _textColor.withValues(alpha: 0.1),
            image:
                experience.details.instructorAvatar != null &&
                    experience.details.instructorAvatar!.isNotEmpty
                ? DecorationImage(
                    image:
                        experience.details.instructorAvatar!.startsWith(
                          'assets/',
                        )
                        ? AssetImage(experience.details.instructorAvatar!)
                              as ImageProvider
                        : FileImage(
                            File(
                              experience.details.instructorAvatar!,
                            ),
                          ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child:
              (experience.details.instructorAvatar == null ||
                  experience.details.instructorAvatar!.isEmpty)
              ? Icon(
                  icon,
                  color: _textColor,
                  size: 40,
                )
              : null,
        ),

        10.gap,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              primaryText,
              textAlign: .center,
              style: TextStyle(
                color: _textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: MyFonts.primaryFont,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              secondaryText,
              textAlign: .center,
              style: TextStyle(
                color: _textColor,
                fontSize: 14,
                fontFamily: MyFonts.opensans,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    final tags = widget.experience.basicInfo.tags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "About Experience",
          style: TextStyle(
            color: _textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: MyFonts.primaryFont,
          ),
        ),
        // const SizedBox(height: 12),
        Text(
          widget.experience.basicInfo.description,
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            height: 1.5,
            fontFamily: MyFonts.opensans,
          ),
        ),
        if (tags.isNotEmpty) ...[
          // const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: _backgroundColor,
                      ),
                    ),
                    backgroundColor: _textColor,
                    side: BorderSide(
                      color: _textColor.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class MapPulsePin extends StatefulWidget {
  final Color prominentColor;
  const MapPulsePin({super.key, required this.prominentColor});

  @override
  State<MapPulsePin> createState() => _MapPulsePinState();
}

class _MapPulsePinState extends State<MapPulsePin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 8, end: 32).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: _animation.value,
              height: _animation.value,
              decoration: BoxDecoration(
                color: widget.prominentColor.withValues(
                  alpha: (1 - (_controller.value)).clamp(0.0, 1.0) * 0.5,
                ),
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              Icons.location_pin,
              color: widget.prominentColor,
              size: 28,
            ),
          ],
        );
      },
    );
  }
}
