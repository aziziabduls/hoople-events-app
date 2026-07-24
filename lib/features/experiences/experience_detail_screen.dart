import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/constants/colors.dart';
import 'package:hoople_mobile_app/core/constants/fonts.dart';
import 'package:hoople_mobile_app/core/constants/images.dart';
import 'package:hoople_mobile_app/core/utils/format_number.dart';
import 'package:hoople_mobile_app/core/utils/num_extensions.dart';
import 'package:hoople_mobile_app/models/experience_model.dart';
import 'package:hoople_mobile_app/widgets/bottom_sheets.dart';
import 'package:hoople_mobile_app/widgets/event_stat_column.dart';
import 'package:hoople_mobile_app/widgets/experience_payment_sheet.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:progressive_blur/progressive_blur.dart';
import 'package:url_launcher/url_launcher.dart';

class ExperienceDetailScreen extends StatefulWidget {
  final Experience experience;
  final bool isPreview;
  final VoidCallback? onPublish;
  final VoidCallback? onShare;

  const ExperienceDetailScreen({
    super.key,
    required this.experience,
    this.isPreview = false,
    this.onPublish,
    this.onShare,
  });

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  Color? _prominentColor;
  final ScrollController _scrollController = ScrollController();
  late final ImageProvider _imageProvider;

  @override
  void initState() {
    super.initState();
    _imageProvider =
        widget.experience.basicInfo.media.banner.startsWith('assets/')
        ? AssetImage(widget.experience.basicInfo.media.banner) as ImageProvider
        : FileImage(File(widget.experience.basicInfo.media.banner));
    _loadProminentColor();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProminentColor() async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        _imageProvider,
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
    } catch (_) {
      // Fallback color if image fails to load or palette generator fails
      _prominentColor = widget.experience.type == ExperienceType.event
          ? MyColor.hooplePurple
          : MyColor.hoopleCharcoal;
      if (mounted) setState(() {});
    }
  }

  int _calculateTotalQuota() {
    return widget.experience.items.fold(0, (sum, item) => sum + item.quota);
  }

  String _getPriceDisplay() {
    if (widget.experience.items.isEmpty) return 'Free';
    final prices = widget.experience.items.map((i) => i.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    if (minPrice == 0) return 'Free';
    return formatNumber(minPrice);
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

  @override
  Widget build(BuildContext context) {
    final prominentColor =
        _prominentColor ??
        (widget.experience.type == ExperienceType.event
            ? MyColor.hooplePurple
            : MyColor.hoopleCharcoal);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: prominentColor,
      body: Stack(
        children: [
          AnimatedBuilder(
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
                        icon: const Icon(Icons.arrow_back_rounded),
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
                        widget.experience.basicInfo.title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    actions: widget.isPreview ? null : _actionAppBar(context),
                    flexibleSpace: _flexibleAppBar(context, prominentColor),
                  ),

                  // Content Body
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(top: 32),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      transform: Matrix4.translationValues(0, -32, 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            // Date / Recurrence Info
                            _buildDateTimeSection(),
                            const SizedBox(height: 32),
                            // About / Description
                            _buildAboutSection(),
                            const SizedBox(height: 32),
                            if (widget.experience.location.mode == 'offline' &&
                                widget
                                        .experience
                                        .location
                                        .physical
                                        ?.coordinates !=
                                    null) ...[
                              _buildLocationMapSection(),
                              const SizedBox(height: 32),
                            ],
                            // Agenda Timeline
                            if (widget
                                .experience
                                .details
                                .agenda
                                .isNotEmpty) ...[
                              _buildAgendaSection(),
                              const SizedBox(height: 32),
                            ],
                            // Tickets / Sessions Selector Title
                            _buildTicketsSection(prominentColor),
                            // Leave extra space at the bottom to avoid overlapping with bottom bar
                            SizedBox(height: widget.isPreview ? 160 : 120),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Sticky Bottom Bar for Preview Mode
          if (widget.isPreview)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildPreviewBottomBar(context, prominentColor),
            ),
        ],
      ),
    );
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
      icon = Icons.loop_rounded;
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
        secondaryText = "Instructor: ${experience.details.instructor}";
      } else {
        secondaryText = "Self-guided Activity";
      }
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: MyFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                secondaryText,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: MyFonts.opensans,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    final tags = widget.experience.basicInfo.tags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About Experience",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: MyFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.experience.basicInfo.description,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
            fontFamily: MyFonts.opensans,
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 12,
                        // color: Colors.white70,
                      ),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: const BorderSide(color: Colors.white10),
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

  Widget _buildLocationMapSection() {
    final physical = widget.experience.location.physical!;
    // final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Location / Venue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: MyFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${physical.venue} • ${physical.address}, ${physical.city}, ${physical.country}",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: MyFonts.opensans,
          ),
        ),
        const SizedBox(height: 16),
        _buildMiniMap(),
      ],
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
                    color: _prominentColor,
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

  Widget _buildAgendaSection() {
    final agenda = widget.experience.details.agenda;
    if (agenda.isEmpty) return const SizedBox.shrink();

    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agenda",
          style: TextStyle(
            color: Colors.white,
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
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'sf-pro',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayStr,
                          style: TextStyle(
                            color: Colors.white,
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.white10,
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
                              color: Colors.white,
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
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.speaker,
                                  style: TextStyle(
                                    color: Colors.white,
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
    );
  }

  Widget _buildTicketsSection(Color prominentColor) {
    final items = widget.experience.items;
    final isSession = widget.experience.type == ExperienceType.activity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSession ? "Available Sessions" : "Tickets",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: MyFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Text(
            "No sessions/tickets currently available.",
            style: TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.description!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],

                          6.gap,
                          if (item.schedule != null) ...[
                            Row(
                              children: [
                                if (item.schedule != null) ...[
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.white60,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'h:mm a',
                                    ).format(item.schedule!.startAt),
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'to',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'h:mm a',
                                    ).format(item.schedule!.endAt),
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          6.gap,
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Slots: ${item.available}/${item.quota}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (item.schedule != null) ...[
                                8.gap,
                                const Icon(
                                  Icons.timelapse_rounded,
                                  size: 14,
                                  color: Colors.white60,
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
                                  style: const TextStyle(
                                    color: Colors.white60,
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
                            color: prominentColor == MyColor.hooplePurple
                                ? MyColor.systemTeal
                                : MyColor.systemYellow,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: widget.isPreview
                              ? null
                              : () => _onTicketSelected(item, prominentColor),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Select",
                            style: TextStyle(
                              fontSize: 12,
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
    );
  }

  FlexibleSpaceBar _flexibleAppBar(BuildContext context, Color prominentColor) {
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
                _imageProvider,
                swipeDismissible: true,
                useSafeArea: true,
                doubleTapZoomable: true,
              );
            },
            child: ProgressiveBlurWidget(
              tintColor: prominentColor.withValues(alpha: 0.5),
              linearGradientBlur: LinearGradientBlur(
                values: [0, 1],
                stops: [0.5, 0.8],
                start: Platform.isAndroid
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              sigma: 24.0,
              blurTextureDimensions: 128,
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      prominentColor,
                    ],
                  ),
                ),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    final scale = 1.05 - (0.05 * value);
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: double.infinity,
                    color: Colors.grey,
                    child: Image(
                      image: _imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
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
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.experience.basicInfo.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    widget.experience.basicInfo.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: MyFonts.primaryFont,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      EventStatColumn(
                        label: 'Price',
                        value: _getPriceDisplay(),
                      ),
                      EventStatColumn(
                        label: 'Capacity',
                        value: formatNumber(_calculateTotalQuota()),
                      ),
                      EventStatColumn(
                        label: 'Location',
                        value: widget.experience.location.mode == 'virtual'
                            ? 'Virtual'
                            : (widget.experience.location.physical?.city ??
                                  'TBD'),
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

  List<Widget> _actionAppBar(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton.filledTonal(
          icon: const Icon(Icons.share_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black26,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Link copied to clipboard!"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildPreviewBottomBar(BuildContext context, Color prominentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Colors.white10),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    widget.onShare ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Preview link shared!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                icon: const Icon(Icons.share_rounded),
                label: const Text("Share Preview"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onPublish,
                icon: const Icon(Icons.publish_rounded),
                label: const Text("Publish"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.hooplePurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  final bool isDark;
  MapBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i + 20, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i + 10), paint);
    }

    final roadPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..lineTo(size.width * 0.5, size.height);

    final path2 = Path()
      ..moveTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.8, size.height);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
