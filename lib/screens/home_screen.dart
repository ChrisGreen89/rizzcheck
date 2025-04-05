import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Import dart:math for Random
import '../providers/hygiene_provider.dart';
import '../services/points_service.dart';
import '../widgets/task_card.dart';
import 'package:confetti/confetti.dart'; // Import confetti
import '../services/notification_service.dart'; // Import NotificationService
import 'calendar_screen.dart'; // Import the calendar screen
import 'package:intl/intl.dart'; // Import intl for DateFormat
import '../models/hygiene_task.dart'; // Import the model

// Convert to StatefulWidget
class HomeScreen extends StatefulWidget {
  // Remove NotificationService field and constructor parameter
  // final NotificationService notificationService;

  // const HomeScreen({super.key, required this.notificationService});
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Listener for PointsService changes
  late PointsService _pointsService;
  late HygieneProvider _hygieneProvider; // Add hygiene provider instance
  // Random generator and list of phrases
  final _random = Random();
  final List<String> _allDonePhrases = [
    "Boom! Go conquer the world (or just play video games).",
    "High Five! 🖐️ You crushed it!",
    "All done! You smell... less bad now. Kidding! 😉",
    "Tasks = SMASHED. Time for snacks?",
    "Nice work! You're officially allowed back in the house.",
    "Cleanliness level: EXPERT.",
    "Look at you, being all responsible and stuff. 👍",
    "Done and dusted! Go forth and be awesome.",
    "Mission Accomplished! What's next, world domination?",
    "You did it! Now go relax, you hygiene hero!",
  ];
  // Confetti controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Get provider instances
    _pointsService = context.read<PointsService>();
    _hygieneProvider = context.read<HygieneProvider>();

    // Add listeners
    _pointsService.addListener(_handlePointsChange);
    _hygieneProvider
        .addListener(_handleHygieneChange); // Add listener for hygiene changes

    // Initialize confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    // Initial check in case a milestone was loaded from a previous session (unlikely but safe)
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndShowMilestone());
  }

  @override
  void dispose() {
    // Remove listeners
    _pointsService.removeListener(_handlePointsChange);
    _hygieneProvider.removeListener(_handleHygieneChange);
    // Dispose confetti controller
    _confettiController.dispose();
    super.dispose();
  }

  // Method to handle state changes from PointsService
  void _handlePointsChange() {
    // Use addPostFrameCallback to safely show dialog after build
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndShowMilestone());
  }

  // Method to handle state changes from HygieneProvider (task completion)
  void _handleHygieneChange() {
    if (!mounted) return;
    // Get the latest state
    final hygieneProvider = context.read<HygieneProvider>();
    // No longer need pointsService here for awarding/marking
    // final pointsService = context.read<PointsService>();

    final incompleteTasks =
        hygieneProvider.todaysTasks.where((task) => !task.isCompleted).toList();

    // UI listener now *only* handles UI effects like confetti
    if (incompleteTasks.isEmpty) {
      // Check if we haven't already awarded points today based on completed dates set
      // This check is now less critical here as points/date are handled in provider,
      // but keeping it prevents unnecessary confetti triggers if listener fires multiple times.
      // final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // if (!pointsService.getCompletedDates().contains(todayString)) {
      //    print("DEBUG: HomeScreen detected completion, awarding points and marking date.");
      //    pointsService.awardDailyCompletionPoints();
      //    pointsService.markDateAsCompleted(DateTime.now());
      // } else {
      //    print("DEBUG: HomeScreen detected completion, but date already marked.");
      // }

      // Play confetti only if it's not already playing
      if (_confettiController.state != ConfettiControllerState.playing) {
        print("DEBUG: Playing confetti from HomeScreen listener.");
        _confettiController.play();
      }
    }
  }

  // Check if a milestone was achieved and show dialog
  void _checkAndShowMilestone() {
    // Check if mounted, important for async callbacks
    if (!mounted) return;

    final milestone = _pointsService.achievedMilestone;
    if (milestone != null) {
      _showMilestoneDialog(milestone);
      _pointsService.clearAchievedMilestone(); // Clear the flag
    }
  }

  // --- Dialog Functions ---

  // Function to show the milestone celebration dialog
  Future<void> _showMilestoneDialog(int streakCount) async {
    String message;
    String title;

    switch (streakCount) {
      case 3:
        title = "3 Days! Not Bad!";
        message = "You didn't forget for 3 days straight! Keep going!";
        break;
      case 7:
        title = "WHOLE WEEK! 🔥";
        message = "Boom! 7 days! You're basically a hygiene ninja now.";
        break;
      case 14:
        title = "TWO WEEKS! LEGEND!";
        message = "14 days?! Are you even human? That's amazing!";
        break;
      case 30:
        title = "A MONTH?! 🤯";
        message =
            "Dude! 30 days! You've totally mastered this whole 'being clean' thing!";
        break;
      default:
        // Default for any other milestones we might add
        title = "Awesome Streak! 🎉";
        message = "You've hit a $streakCount day streak! Excellent work!";
        break;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Yay!'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show reset confirmation dialog
  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Reset State?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'This will reset all task completions, points, and streak count.'),
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Access providers using the original context
                final pointsService = context.read<PointsService>();
                final hygieneProvider = context.read<HygieneProvider>();

                // Call reset methods
                pointsService.resetData();
                hygieneProvider.resetDebugState();

                print("DEBUG: State reset triggered.");

                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show the set streak dialog
  Future<void> _showSetStreakDialog(BuildContext context) async {
    final pointsService = context.read<PointsService>();
    final streakController =
        TextEditingController(text: pointsService.streak.toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Set Streak (Debug)'),
          content: TextField(
            controller: streakController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Enter new streak count'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Set'),
              onPressed: () {
                final newStreak = int.tryParse(streakController.text);
                if (newStreak != null && newStreak >= 0) {
                  pointsService.setStreakDebug(newStreak);
                  print("DEBUG: Attempting to set streak to $newStreak");
                } else {
                  // Optional: Show a snackbar for invalid input
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid streak number.')),
                  );
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // No need to read _pointsService here, handled by listener
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boygiene'),
        actions: [
          // Remove Calendar button - navigation now handled by bottom bar
          // IconButton(
          //   icon: const Icon(Icons.calendar_month),
          //   tooltip: 'View Progress Calendar',
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const CalendarScreen()),
          //     );
          //   },
          // ),
          // Reset button (remains the same)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset State (Debug)',
            onPressed: () {
              _showResetConfirmationDialog(context);
            },
          ),
          // Add debug button to set streak
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Set Streak (Debug)',
            onPressed: () {
              _showSetStreakDialog(context);
            },
          ),
          // Button to check pending notifications
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Check Pending Notifications (Debug)',
            onPressed: () async {
              try {
                // Use context.read directly here
                final notificationService = context.read<NotificationService>();
                final pendingRequests = await notificationService.pluginInstance
                    .pendingNotificationRequests();
                print("--- Pending Notification Requests ---");
                if (pendingRequests.isEmpty) {
                  print("  No pending requests found.");
                } else {
                  for (var request in pendingRequests) {
                    print("  ID: ${request.id}");
                    print("    Title: ${request.title}");
                    print("    Body: ${request.body}");
                    print("    Payload: ${request.payload}");
                  }
                }
                print("-----------------------------------");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Pending notifications printed to console.')),
                  );
                }
              } catch (e) {
                print("ERROR checking pending notifications: $e");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error checking notifications: $e')),
                  );
                }
              }
            },
          ),
          // Button to trigger a test notification
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Send Test Notification (Debug)',
            onPressed: () {
              // Use context.read directly here
              final notificationService = context.read<NotificationService>();
              notificationService.scheduleTestNotification();
              // Use ScaffoldMessenger.of(context) safely
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Test notification scheduled for 5s.')),
                );
              }
            },
          ),
        ],
      ),
      // Use a Stack to overlay confetti
      body: Stack(
        alignment: Alignment.topCenter, // Align confetti to top center
        children: [
          // Main content column
          Builder(builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Points/Streak Header
                Consumer<PointsService>(
                  builder: (context, pointsService, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Points: ${pointsService.points}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Streak: ${pointsService.streak} 🔥',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 1),
                // Task List Area - Use Selector for efficiency
                Expanded(
                  child: Selector<HygieneProvider, List<HygieneTask>>(
                    // Select only the list of incomplete tasks for today
                    selector: (context, provider) {
                      final todays = provider.todaysTasks;
                      final incomplete =
                          todays.where((task) => !task.isCompleted).toList();
                      print(
                          "Selector selecting ${incomplete.length} incomplete tasks"); // Debug
                      return incomplete;
                    },
                    // The selector automatically compares lists based on item equality (thanks to Equatable)
                    builder: (context, incompleteTasks, child) {
                      // This builder now only runs when the list content changes
                      print(
                          "--- HomeScreen UI Rebuilding for ${incompleteTasks.length} tasks ---");

                      // --- Remove duplicate debug prints from here ---
                      // print("Total tasks in provider: ${provider.tasks.length}");
                      // final allTodaysTasks = provider.todaysTasks;
                      // print("Tasks scheduled for today: ${allTodaysTasks.length}");
                      // print("Incomplete tasks for today: ${incompleteTasks.length}");

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (incompleteTasks.isEmpty)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'All Done Today! High Five! 🖐️',
                                        // Use headlineMedium for dark text, override size
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium // Keep for color
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    20 // Explicitly set size
                                                ),
                                      ),
                                    ),
                                    Text(
                                      _allDonePhrases[_random
                                          .nextInt(_allDonePhrases.length)],
                                      textAlign: TextAlign.center,
                                      // Use a body style for the sub-phrase
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Today\'s Tasks',
                                      // Use headlineMedium for dark text, override size
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium // Keep for color
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  20 // Explicitly set size
                                              ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      itemCount: incompleteTasks.length,
                                      itemBuilder: (context, index) {
                                        final task = incompleteTasks[index];
                                        return TaskCard(
                                            key: ValueKey(task.id), task: task);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }),
          // Confetti Widget positioned at the top
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality:
                  BlastDirectionality.explosive, // Or try .directional
              shouldLoop: false,
              numberOfParticles: 20,
              gravity: 0.1, // Make it fall slower
              emissionFrequency: 0.05,
              // colors: const [ // Optional: Customize colors
              //   Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              // ],
            ),
          ),
        ],
      ),
    );
  }
}
