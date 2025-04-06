import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Import dart:math for Random
import 'package:intl/intl.dart'; // Import intl for DateFormat
import 'package:confetti/confetti.dart'; // Import confetti

import '../providers/hygiene_provider.dart';
import '../services/points_service.dart';
import '../services/notification_service.dart'; // Needed for ModernHeader actions
import '../models/hygiene_task.dart';
import '../widgets/task_card.dart';
import '../widgets/modern_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PointsService _pointsService;
  late HygieneProvider _hygieneProvider;
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
  final List<String> _funnyQuotes = [
    "Is that... deodorant? Look at you adulting!",
    "Smelling good is part of the rizz checklist.",
    "Remember: Clean socks are happy socks.",
    "Did you brush your teeth? Your smile will thank you (and so will everyone else).",
    "Water: good for hydration, also good for washing.",
    "Conquered the shower today? High five!",
    "Face wash: defeating the forces of pizza grease one wash at a time.",
    "Hair looking sharp! Or at least... clean.",
    "Don't forget the bits behind the ears. It's prime real estate for... stuff.",
    "Today's goal: Smell less like a locker room.",
    "Keep calm and brush on.",
    "Hygiene: It's like a superpower, but less flashy.",
    "Soap is your friend. Don't ghost your friend.",
  ];
  late String _dailyQuote = "";
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _pointsService = context.read<PointsService>();
    _hygieneProvider = context.read<HygieneProvider>();
    _pointsService.addListener(_handlePointsChange);
    _hygieneProvider.addListener(_handleHygieneChange);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _selectDailyQuote();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndShowMilestone());
  }

  @override
  void dispose() {
    _pointsService.removeListener(_handlePointsChange);
    _hygieneProvider.removeListener(_handleHygieneChange);
    _confettiController.dispose();
    super.dispose();
  }

  void _handlePointsChange() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndShowMilestone());
  }

  void _handleHygieneChange() {
    if (!mounted) return;
    final incompleteTasks = _hygieneProvider.todaysTasks
        .where((task) => !task.isCompleted)
        .toList();
    if (incompleteTasks.isEmpty &&
        _confettiController.state != ConfettiControllerState.playing) {
      print("DEBUG: Playing confetti from HomeScreen listener.");
      _confettiController.play();
    }
  }

  void _checkAndShowMilestone() {
    if (!mounted) return;
    final milestone = _pointsService.achievedMilestone;
    if (milestone != null) {
      _showMilestoneDialog(milestone);
      _pointsService.clearAchievedMilestone();
    }
  }

  void _selectDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = int.parse(DateFormat("D").format(now));
    final quoteIndex = dayOfYear % _funnyQuotes.length;
    if (mounted) {
      setState(() {
        _dailyQuote = _funnyQuotes[quoteIndex];
      });
    }
    print(
        "DEBUG: Selected quote for day $dayOfYear (index $quoteIndex): $_dailyQuote");
  }

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
        title = "Awesome Streak! 🎉";
        message = "You've hit a $streakCount day streak! Excellent work!";
        break;
    }

    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Builder(builder: (buildContext) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernHeader(
                    dailyQuote: _dailyQuote,
                    showDebugActions: true,
                    homeScreenContext: buildContext,
                  ),
                  Expanded(
                    child: Selector<HygieneProvider, List<HygieneTask>>(
                      selector: (_, provider) => provider.todaysTasks
                          .where((task) => !task.isCompleted)
                          .toList(),
                      builder: (context, incompleteTasks, child) {
                        print(
                            "--- HomeScreen UI Rebuilding for ${incompleteTasks.length} tasks ---");
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (incompleteTasks.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0, left: 8, right: 8),
                                        child: Text(
                                          'All Done Today! High Five! 🖐️',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        _allDonePhrases[_random
                                            .nextInt(_allDonePhrases.length)],
                                        textAlign: TextAlign.center,
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
                                      padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 16.0,
                                          left: 16.0,
                                          right: 16.0),
                                      child: Text(
                                        'Today\'s Tasks',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.8),
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
                                              key: ValueKey(task.id),
                                              task: task);
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
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 20,
              gravity: 0.1,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
