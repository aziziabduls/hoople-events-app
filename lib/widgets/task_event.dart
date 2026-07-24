import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoople_mobile_app/models/event_model.dart';

class TaskEvents extends StatefulWidget {
  final EventModel event;
  final Color? prominentColor;
  const TaskEvents({super.key, required this.event, this.prominentColor});

  @override
  State<TaskEvents> createState() => _TaskEventsState();
}

class _TaskEventsState extends State<TaskEvents> {
  bool _isExpanded = false;
  late List<Map<String, dynamic>> _tasks;

  final List<String> _taskTypes = [
    'Face Swap',
    'Object Identification',
    'Photo Challenge',
    'Video Challenge',
    'GPS Check-In',
    'Open-Ended Answer',
    'Exact Answer',
    'QR Code',
    'Single Correct Answer',
    'Multiple Correct Answers',
  ];

  @override
  void initState() {
    super.initState();
    _generateRandomTasks();
  }

  void _generateRandomTasks() {
    _tasks = List.generate(8, (index) {
      final type = _taskTypes[index % _taskTypes.length];
      return {
        'name': '$type Challenge',
        'type': type,
        'points': (index + 1) * 50,
        'icon': _getIconForType(type),
      };
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Face Swap':
        return Icons.face_retouching_natural;
      case 'Object Identification':
        return Icons.image_search;
      case 'Photo Challenge':
        return Icons.camera_alt;
      case 'Video Challenge':
        return Icons.videocam;
      case 'GPS Check-In':
        return Icons.location_on;
      case 'Open-Ended Answer':
        return Icons.notes;
      case 'Exact Answer':
        return Icons.short_text;
      case 'QR Code':
        return Icons.qr_code_scanner;
      case 'Single Correct Answer':
        return Icons.radio_button_checked;
      case 'Multiple Correct Answers':
        return Icons.checklist;
      default:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tasks (${_tasks.length})",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'sf-pro',
              ),
            ),
            if (widget.event.isFollowing)
              TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? "Stack" : "View All",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: child,
              ),
            );
          },
          child: _isExpanded ? _buildVerticalList() : _buildStackedTasks(),
        ),
      ],
    );
  }

  Widget _buildStackedTasks() {
    return GestureDetector(
      onTap: widget.event.isFollowing
          ? () => setState(() => _isExpanded = true)
          : null,
      child: Center(
        child: SizedBox(
          height: 160,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.topCenter,
            children: List.generate(3, (index) {
              final task = _tasks[index];
              return Positioned(
                top: index * 15.0,
                child: Transform.scale(
                  scale: 1.0 - (index * 0.05),
                  child: _buildTaskCard(
                    task,
                    width: MediaQuery.of(context).size.width * 0.85,
                  ),
                ),
              );
            }).reversed.toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildTaskCard(_tasks[index], isWide: true);
      },
    );
  }

  Widget _buildTaskCard(
    Map<String, dynamic> task, {
    double? width,
    bool isWide = false,
  }) {
    return GestureDetector(
      onTap: () {
        print('ontap');
        context.push('/result');
      },
      onDoubleTap: () {
        print('ondoubletap');
      },
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [
            if (!isWide)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                task['icon'] as IconData,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    overflow: .ellipsis,
                    task['name'] as String,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sf-pro',
                    ),
                  ),
                  Text(
                    task['type'] as String,
                    style: const TextStyle(color: Colors.black38, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "+${task['points']} pts",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
