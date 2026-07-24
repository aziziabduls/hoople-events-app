import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/constants/colors.dart';
import 'package:hoople_mobile_app/core/constants/fonts.dart';
import 'package:hoople_mobile_app/features/experiences/experience_detail_screen.dart';
import 'package:hoople_mobile_app/models/experience_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ExperienceFormScreen extends StatefulWidget {
  const ExperienceFormScreen({super.key});

  @override
  State<ExperienceFormScreen> createState() => _ExperienceFormScreenState();
}

class _ExperienceFormScreenState extends State<ExperienceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // State Variables
  ExperienceType _experienceType = ExperienceType.event;
  String _locationMode = 'offline';
  String _selectedBanner = 'assets/images/FlutterConf2026.png';
  // String _selectedBanner = '';

  // Preset Banners List
  // final List<Map<String, String>> _presetBanners = [
  //   {
  //     'path': 'assets/images/FlutterConf2026.png',
  //     'label': 'Conference',
  //   },
  //   {
  //     'path': 'assets/images/yoga-a.jpg',
  //     'label': 'Yoga / Health',
  //   },
  //   {
  //     'path': 'assets/images/italian_cooking_class.jpg',
  //     'label': 'Cooking',
  //   },
  //   {
  //     'path': 'assets/images/pestapora.jpg',
  //     'label': 'Music Festival',
  //   },
  //   {
  //     'path': 'assets/images/sat_running_club.jpg',
  //     'label': 'Sport / Run',
  //   },
  // ];

  final List<Map<String, String>> _presetBanners = [];

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _venueController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'Indonesia');
  final _virtualUrlController = TextEditingController();

  // Activity Specific Fields
  final _instructorController = TextEditingController();
  String _recurrenceFreq = 'WEEKLY';
  final List<String> _selectedRecurrenceDays = ['MO', 'WE'];

  // Event Specific Fields
  DateTime? _startDate;
  DateTime? _endDate;

  // Tickets / Sessions list
  final List<_ItemFormFields> _items = [];

  // Tags Fields
  final List<String> _selectedTags = [];
  final _customTagController = TextEditingController();
  String _selectedDropdownCategory = 'Technology';

  final Map<String, List<String>> _recommendedTagsMap = {
    'Technology': ['flutter', 'mobile', 'conference', 'coding', 'developer'],
    'Health': ['yoga', 'fitness', 'mindfulness', 'wellness', 'meditation'],
    'Cooking': ['cooking', 'food', 'baking', 'culinary', 'beverages'],
    'Music': ['music', 'festival', 'concert', 'live', 'acoustic'],
    'Sport': ['running', 'fitness', 'cycling', 'hiking', 'workout'],
    'Other': ['general', 'community', 'workshop'],
  };

  @override
  void initState() {
    super.initState();
    _selectedDropdownCategory = 'Technology';
    _categoryController.text = 'Technology';
    _selectedTags.addAll(['flutter', 'mobile', 'conference']);
    // Start with one ticket item
    _addItemField();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _virtualUrlController.dispose();
    _instructorController.dispose();
    _customTagController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItemField() {
    setState(() {
      _items.add(_ItemFormFields());
    });
  }

  void _removeItemField(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You need at least one ticket/session item."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedBanner = image.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: MyColor.hooplePurple,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: MyColor.hooplePurple,
                onPrimary: Colors.white,
                surface: Theme.of(context).scaffoldBackgroundColor,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final fullDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) {
            _startDate = fullDateTime;
          } else {
            _endDate = fullDateTime;
          }
        });
      }
    }
  }

  Experience _buildExperienceObject() {
    final id = "exp_${DateTime.now().millisecondsSinceEpoch}";

    // Construct Location
    final location = Location(
      mode: _locationMode,
      physical: _locationMode == 'offline'
          ? PhysicalLocation(
              venue: _venueController.text,
              address: _addressController.text,
              city: _cityController.text,
              country: _countryController.text,
              coordinates: Coordinate(latitude: -6.2, longitude: 106.8),
            )
          : null,
      virtual: _locationMode == 'virtual'
          ? VirtualLocation(url: _virtualUrlController.text)
          : null,
    );

    // Construct Recurrence Rule
    Recurrence? recurrence;
    if (_experienceType == ExperienceType.activity) {
      final days = _selectedRecurrenceDays.join(',');
      recurrence = Recurrence(
        rule: "FREQ=$_recurrenceFreq;BYDAY=$days",
      );
    }

    // Construct Schedule
    Schedule? schedule;
    if (_experienceType == ExperienceType.event) {
      schedule = Schedule(
        timezone: 'Asia/Jakarta',
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    final details = ExperienceDetails(
      schedule: schedule,
      agenda: [],
      instructor: _instructorController.text.isNotEmpty
          ? _instructorController.text
          : null,
      recurrence: recurrence,
    );

    // Construct Items
    final experienceItems = _items.map((field) {
      final price = int.tryParse(field.priceController.text) ?? 0;
      final quota = int.tryParse(field.quotaController.text) ?? 10;
      final isSession = _experienceType == ExperienceType.activity;

      return ExperienceItem(
        id: "item_${DateTime.now().microsecondsSinceEpoch}",
        type: isSession ? ItemType.session : ItemType.ticket,
        name: field.nameController.text,
        description: field.descController.text,
        price: price,
        quota: quota,
        available: quota,
        schedule: isSession && _startDate != null && _endDate != null
            ? ItemSchedule(startAt: _startDate!, endAt: _endDate!)
            : null,
      );
    }).toList();

    return Experience(
      id: id,
      type: _experienceType,
      status: 'published',
      organizerId: 'org_user',
      basicInfo: BasicInfo(
        title: _titleController.text,
        slug: _titleController.text.toLowerCase().replaceAll(' ', '-'),
        description: _descController.text,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : 'General',
        media: Media(thumbnail: _selectedBanner, banner: _selectedBanner),
        tags: List<String>.from(_selectedTags),
      ),
      location: location,
      details: details,
      items: experienceItems,
    );
  }

  void _navigateToPreview() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_experienceType == ExperienceType.event) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select start and end date for the event."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("End date must be after start date."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final experience = _buildExperienceObject();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExperienceDetailScreen(
          experience: experience,
          isPreview: true,
          onPublish: () {
            // Return the created experience back to the caller of form screen
            Navigator.pop(context); // Close preview screen
            Navigator.pop(
              context,
              experience,
            ); // Close form screen and return object
          },
          onShare: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Preview link for '${experience.basicInfo.title}' copied!",
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Experience",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Segmented selector for Event vs Activity
            Text(
              "Experience Type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Basic Information
            _buildSectionHeader("Basic Information"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _titleController,
              label: "Title",
              hint: "e.g., Jakarta Tech Meetup",
              validator: (v) =>
                  v == null || v.isEmpty ? "Title is required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descController,
              label: "Description",
              hint: "Provide an amazing description of the experience...",
              maxLines: 4,
              validator: (v) =>
                  v == null || v.isEmpty ? "Description is required" : null,
            ),
            const SizedBox(height: 16),
            _buildCategoryAndTagsSection(),
            const SizedBox(height: 24),

            // Visual Banner Selector
            _buildSectionHeader("Select Banner Image"),
            const SizedBox(height: 16),
            _buildBannerSelector(),
            const SizedBox(height: 24),

            // Location Configuration
            _buildSectionHeader("Location Details"),
            const SizedBox(height: 16),
            _buildLocationModeSelector(),
            const SizedBox(height: 16),
            if (_locationMode == 'offline') ...[
              _buildTextField(
                controller: _venueController,
                label: "Venue Name",
                hint: "e.g., Grand Hall Senayan",
                validator: (v) =>
                    _locationMode == 'offline' && (v == null || v.isEmpty)
                    ? "Venue is required"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: "Street Address",
                hint: "e.g., Jl. Sudirman Kav 21",
                validator: (v) =>
                    _locationMode == 'offline' && (v == null || v.isEmpty)
                    ? "Address is required"
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: "City",
                      hint: "e.g., Jakarta",
                      validator: (v) =>
                          _locationMode == 'offline' && (v == null || v.isEmpty)
                          ? "City is required"
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _countryController,
                      label: "Country",
                      hint: "e.g., Indonesia",
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildTextField(
                controller: _virtualUrlController,
                label: "Virtual Meeting URL",
                hint: "e.g., https://zoom.us/j/123456",
                validator: (v) =>
                    _locationMode == 'virtual' && (v == null || v.isEmpty)
                    ? "Meeting URL is required"
                    : null,
              ),
            ],
            const SizedBox(height: 24),

            // Schedule Details
            _buildSectionHeader(
              _experienceType == ExperienceType.event
                  ? "Date and Time"
                  : "Schedule & Instructor",
            ),
            const SizedBox(height: 16),
            if (_experienceType == ExperienceType.event)
              _buildEventDatePicker()
            else
              _buildActivityScheduleFields(),
            const SizedBox(height: 24),

            // Tickets or Sessions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(
                  _experienceType == ExperienceType.event
                      ? "Tickets"
                      : "Sessions",
                ),
                TextButton.icon(
                  onPressed: _addItemField,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                  style: TextButton.styleFrom(
                    foregroundColor: MyColor.systemTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildItemsList(),
            const SizedBox(height: 40),

            // Preview Action
            ElevatedButton(
              onPressed: _navigateToPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.hooplePurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Preview Experience",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
        fontFamily: MyFonts.primaryFont,
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorOption(
              label: "Event",
              icon: Icons.event_rounded,
              isSelected: _experienceType == ExperienceType.event,
              onTap: () =>
                  setState(() => _experienceType = ExperienceType.event),
            ),
          ),
          Expanded(
            child: _buildSelectorOption(
              label: "Activity",
              icon: Icons.run_circle_rounded,
              isSelected: _experienceType == ExperienceType.activity,
              onTap: () =>
                  setState(() => _experienceType = ExperienceType.activity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationModeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorOption(
              label: "Physical / Offline",
              icon: Icons.location_on_rounded,
              isSelected: _locationMode == 'offline',
              onTap: () => setState(() => _locationMode = 'offline'),
            ),
          ),
          Expanded(
            child: _buildSelectorOption(
              label: "Online / Virtual",
              icon: Icons.videocam_rounded,
              isSelected: _locationMode == 'virtual',
              onTap: () => setState(() => _locationMode = 'virtual'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? MyColor.hooplePurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 250),
          curve: Curves.ease,
          tween: ColorTween(
            end: isSelected
                ? Colors.white
                : (isDark ? Colors.white60 : Colors.black54),
          ),
          builder: (context, color, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: MyColor.hooplePurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _presetBanners.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isCustomSelected = !_selectedBanner.startsWith('assets/');
            return GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCustomSelected
                        ? MyColor.systemTeal
                        : (isDark ? Colors.white10 : Colors.black12),
                    width: isCustomSelected ? 3.0 : 1.0,
                  ),
                  image: isCustomSelected
                      ? DecorationImage(
                          image: FileImage(File(_selectedBanner)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: isCustomSelected
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Custom Image",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: isDark ? Colors.white60 : Colors.black54,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "From Gallery",
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }

          final banner = _presetBanners[index - 1];
          final isSelected = banner['path'] == _selectedBanner;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBanner = banner['path']!;
              });
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? MyColor.systemTeal
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: isSelected ? 3.0 : 1.0,
                ),
                image: DecorationImage(
                  image: AssetImage(banner['path']!),
                  fit: BoxFit.cover,
                  colorFilter: isSelected
                      ? null
                      : ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.4),
                          BlendMode.darken,
                        ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    banner['label']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final df = DateFormat('EEE, d MMM yyyy, hh:mm a');
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start Date",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _startDate != null ? df.format(_startDate!) : "Select Date",
                    style: TextStyle(
                      color: _startDate != null
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white30 : Colors.black38),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "End Date",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _endDate != null ? df.format(_endDate!) : "Select Date",
                    style: TextStyle(
                      color: _endDate != null
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white30 : Colors.black38),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityScheduleFields() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _instructorController,
          label: "Instructor Name",
          hint: "e.g., Siti Namaste",
        ),
        const SizedBox(height: 16),
        Text(
          "Recurrence Frequence",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _recurrenceFreq,
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
            DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
            DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _recurrenceFreq = v);
          },
        ),
        const SizedBox(height: 16),
        Text(
          "Recurrence Days",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildDaysOfWeekSelector(),
      ],
    );
  }

  Widget _buildDaysOfWeekSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, String>> days = [
      {'code': 'MO', 'label': 'Mon'},
      {'code': 'TU', 'label': 'Tue'},
      {'code': 'WE', 'label': 'Wed'},
      {'code': 'TH', 'label': 'Thu'},
      {'code': 'FR', 'label': 'Fri'},
      {'code': 'SA', 'label': 'Sat'},
      {'code': 'SU', 'label': 'Sun'},
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: days.map((day) {
        final isSelected = _selectedRecurrenceDays.contains(day['code']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                if (_selectedRecurrenceDays.length > 1) {
                  _selectedRecurrenceDays.remove(day['code']);
                }
              } else {
                _selectedRecurrenceDays.add(day['code']!);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColor.hooplePurple
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            child: Text(
              day['label']!,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final number = index + 1;
        final isSession = _experienceType == ExperienceType.activity;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSession ? "Session #$number" : "Ticket #$number",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => _removeItemField(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: item.nameController,
                label: isSession ? "Session Name" : "Ticket Name",
                hint: isSession
                    ? "e.g., Morning Flow Session"
                    : "e.g., VIP Ticket",
                validator: (v) =>
                    v == null || v.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: item.descController,
                label: "Description (Optional)",
                hint: "What is included...",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: item.priceController,
                      label: "Price (Rp)",
                      hint: "0 for Free",
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Price is required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: item.quotaController,
                      label: "Total Quota / Slots",
                      hint: "e.g., 20",
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Quota is required" : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryAndTagsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = [
      'Technology',
      'Health',
      'Cooking',
      'Music',
      'Sport',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDropdownCategory,
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          items: categories
              .map(
                (cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _selectedDropdownCategory = v;
                if (v == 'Other') {
                  _categoryController.clear();
                } else {
                  _categoryController.text = v;
                }
                _selectedTags.clear();
                if (_recommendedTagsMap.containsKey(v)) {
                  _selectedTags.addAll(_recommendedTagsMap[v]!);
                }
              });
            }
          },
        ),
        if (_selectedDropdownCategory == 'Other') ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _categoryController,
            label: "Custom Category",
            hint: "Enter your custom category",
            validator: (v) =>
                v == null || v.isEmpty ? "Custom category is required" : null,
          ),
        ],
        const SizedBox(height: 16),
        Text(
          "Recommended Tags (Tap to toggle)",
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final recTags = _recommendedTagsMap[_categoryController.text] ?? [];
            if (recTags.isEmpty) {
              return Text(
                "No recommendations available.",
                style: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black38,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text('#$tag'),
                  selected: isSelected,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                    fontSize: 12,
                  ),
                  selectedColor: MyColor.hooplePurple,
                  checkmarkColor: Colors.white,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? Colors.white10 : Colors.black12),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (!_selectedTags.contains(tag)) {
                          _selectedTags.add(tag);
                        }
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          "Add Custom Tag",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customTagController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Enter a tag (e.g., concert)",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onFieldSubmitted: (v) {
                  _addCustomTag();
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addCustomTag,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: MyColor.systemTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        if (_selectedTags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            "Selected Tags",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags
                .map(
                  (tag) => InputChip(
                    label: Text('#$tag'),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: MyColor.hooplePurple,
                    deleteIconColor: Colors.white70,
                    onDeleted: () {
                      setState(() {
                        _selectedTags.remove(tag);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  void _addCustomTag() {
    final text = _customTagController.text.trim().toLowerCase();
    if (text.isNotEmpty) {
      setState(() {
        if (!_selectedTags.contains(text)) {
          _selectedTags.add(text);
        }
        _customTagController.clear();
      });
    }
  }
}

class _ItemFormFields {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final quotaController = TextEditingController();

  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    quotaController.dispose();
  }
}
