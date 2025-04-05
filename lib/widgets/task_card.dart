import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hygiene_task.dart';
import '../providers/hygiene_provider.dart';
import '../services/points_service.dart';

// Convert to StatefulWidget
class TaskCard extends StatefulWidget {
  final HygieneTask task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

// Add SingleTickerProviderStateMixin for AnimationController vsync
class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation; // Add scale animation
  bool _isAnimating = false; // To disable checkbox during animation
  // Re-add local state for checkbox visual appearance
  bool _localCheckedState = false;

  @override
  void initState() {
    super.initState();
    // Re-initialize local state from the actual task state
    _localCheckedState = widget.task.isCompleted;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Animation duration
      vsync: this,
    );

    // Curved animation for both opacity and scale
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Use a curve like easeInOut
    );

    // Opacity: 1.0 -> 0.0
    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(curvedAnimation);
    // Scale: 1.0 -> 0.0
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(curvedAnimation);

    // Add listener to trigger state update after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Ensure task isn't already marked completed by another means
        if (!widget.task.isCompleted) {
          // Access providers using context.read here, as it's outside build
          // This now ONLY toggles the state in HygieneProvider.
          // HygieneProvider is responsible for calling PointsService.
          final hygieneProvider = context.read<HygieneProvider>();
          // final pointsService = context.read<PointsService>(); // REMOVED

          hygieneProvider.toggleTaskCompletion(widget.task.id);
          // Pass the current time when the animation completes
          // pointsService.completeTask(DateTime.now()); // REMOVED
          // No need to call setState, provider will trigger rebuild
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No need to read providers here anymore, moved to animation listener

    // --- DEBUG LOGGING START ---
    print(
        "Building TaskCard for: ${widget.task.title} (ID: ${widget.task.id})");
    // --- DEBUG LOGGING END ---

    // Wrap FadeTransition with ScaleTransition
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.center, // Shrink towards the center
      child: FadeTransition(
        opacity: _opacityAnimation,
        // Card properties like elevation, margin, shape, color are now handled by cardTheme in main.dart
        // elevation: 2.0,
        // margin: const EdgeInsets.only(bottom: 12.0),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10.0),
        // ),
        child: Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: Checkbox(
              // Revert value to use local state
              value: _localCheckedState,
              // activeColor is handled by theme
              // activeColor: Colors.teal,
              // Revert disable condition to include local state
              onChanged: (_isAnimating || _localCheckedState)
                  ? null
                  : (bool? value) {
                      if (value == true) {
                        // Revert setState to update local state
                        setState(() {
                          _isAnimating = true;
                          _localCheckedState = true;
                        });
                        // Add a delay before starting the animation
                        Future.delayed(const Duration(milliseconds: 250), () {
                          if (mounted) {
                            _controller.forward();
                          }
                        });
                      }
                    },
            ),
            title: Text(
              widget.task.title, // Use widget.task here
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration:
                    widget.task.isCompleted ? TextDecoration.lineThrough : null,
                color: widget.task.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: Text(widget.task.description), // Use widget.task here
          ),
        ),
      ),
    );
  }
}
