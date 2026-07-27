import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/constants/colors.dart';
import 'package:hoople_mobile_app/core/constants/fonts.dart';
import 'package:hoople_mobile_app/features/events/detail_screen.dart';
import 'package:hoople_mobile_app/models/experience_model.dart';
import 'package:hoople_mobile_app/widgets/styled_back_button.dart';
import 'package:palette_generator/palette_generator.dart';

class SearchScreen extends StatefulWidget {
  final List<Experience> experiences;

  const SearchScreen({super.key, required this.experiences});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Experience> _searchResults = [];
  final List<String> _suggestions = ['Flutter', 'Yoga', 'Cooking'];
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Color?> getProminentColor(Experience experience) async {
    try {
      final imageProvider =
          experience.basicInfo.media.banner.startsWith('assets/')
          ? AssetImage(experience.basicInfo.media.banner) as ImageProvider
          : FileImage(File(experience.basicInfo.media.banner));

      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(200, 200),
      );

      if (palette.dominantColor?.color != null) {
        return Color.lerp(
          palette.dominantColor?.color,
          Colors.black,
          0.5,
        );
      }
    } catch (_) {
      // Fallback if image/palette fails
    }
    return experience.type == ExperienceType.event
        ? MyColor.hooplePurple
        : MyColor.hoopleCharcoal;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = widget.experiences.where((exp) {
        final title = exp.basicInfo.title.toLowerCase();
        final desc = exp.basicInfo.description.toLowerCase();
        final cat = exp.basicInfo.category.toLowerCase();
        final tags = exp.basicInfo.tags.map((t) => t.toLowerCase()).toList();

        return title.contains(query) ||
            desc.contains(query) ||
            cat.contains(query) ||
            tags.any((t) => t.contains(query));
      }).toList();
    });
  }

  void _applySuggestion(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: suggestion.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: StyledBackButton(),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: "Search experiences, tags, classes...",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            placeholderStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            itemColor: isDark ? Colors.white60 : Colors.black54,
            onSuffixTap: () {
              _searchController.clear();
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: _searchController.text.trim().isEmpty
                ? _buildSuggestionsView(isDark, theme)
                : _buildResultsView(isDark, theme),
          ),
          if (_isNavigating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsView(bool isDark, ThemeData theme) {
    // Show featured experiences first, fallback to first 10
    final featuredList = widget.experiences
        .where((e) => e.metadata?.isFeatured ?? false)
        .toList();
    final discoverList = featuredList.isNotEmpty
        ? featuredList.take(10).toList()
        : widget.experiences.take(10).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        Text(
          "Popular Suggestions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
            fontFamily: MyFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              labelStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              side: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => _applySuggestion(suggestion),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        Text(
          "Discover Experiences",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
            fontFamily: MyFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 16),
        if (discoverList.isEmpty)
          Center(
            child: Text(
              "No experiences available.",
              style: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
            ),
          )
        else
          ...discoverList.map(
            (exp) => _buildExperienceCard(context, exp, isDark),
          ),
      ],
    );
  }

  Widget _buildResultsView(bool isDark, ThemeData theme) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            const SizedBox(height: 16),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try searching for something else",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final exp = _searchResults[index];
        return _buildExperienceCard(context, exp, isDark);
      },
    );
  }

  Widget _buildExperienceCard(
    BuildContext context,
    Experience exp,
    bool isDark,
  ) {
    final isEvent = exp.type == ExperienceType.event;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark
          ? Colors.white.withValues(alpha: 0.03)
          : Colors.black.withValues(alpha: 0.02),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          // if (_isNavigating) return;
          // setState(() {
          //   _isNavigating = true;
          // });

          // try {
          //   final color = await getProminentColor(exp);
          //   if (context.mounted) {
          //     context.push(
          //       '/experience-detail',
          //       extra: {
          //         'experience': exp,
          //         'prominentColor': color,
          //       },
          //     ).then((_) {
          //       if (mounted) setState(() {});
          //     });
          //   }
          // } finally {
          //   if (mounted) {
          //     setState(() {
          //       _isNavigating = false;
          //     });
          //   }
          // }

          if (_isNavigating) return;
          setState(() {
            _isNavigating = true;
          });

          try {
            if (context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    experience: exp,
                  ),
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isNavigating = false;
              });
            }
          }
        },
        child: Row(
          children: [
            // Thumbnail Banner
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: exp.basicInfo.media.banner.startsWith('assets/')
                      ? AssetImage(exp.basicInfo.media.banner)
                      : FileImage(File(exp.basicInfo.media.banner))
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isEvent
                            ? MyColor.hooplePurple.withValues(alpha: 0.2)
                            : MyColor.systemTeal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exp.basicInfo.category,
                        style: TextStyle(
                          color: isEvent
                              ? MyColor.hooplePurple
                              : MyColor.systemTeal,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      exp.basicInfo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: MyFonts.primaryFont,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Location or Details
                    Text(
                      exp.location.mode == 'virtual'
                          ? 'Virtual Session'
                          : (exp.location.physical?.venue ?? 'Offline'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
