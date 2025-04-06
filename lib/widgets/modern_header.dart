import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';
import '../services/notification_service.dart'; // Needed for debug buttons' onPressed
import '../providers/hygiene_provider.dart'; // Import HygieneProvider

// Reusable Header Widget (Now includes Title/Quote again)
class ModernHeader extends StatelessWidget {
  final String dailyQuote; // Re-add dailyQuote parameter
  final bool showDebugActions; // Control visibility of debug buttons
  final BuildContext?
      homeScreenContext; // Needed for dialogs/scaffold messenger

  const ModernHeader({
    super.key,
    required this.dailyQuote, // Re-add requirement
    this.showDebugActions = false, // Default to false
    this.homeScreenContext, // Optional context from home screen
  });

  // --- Dialog Functions (Copied from HomeScreen, require context) ---

  // Function to show reset confirmation dialog
  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    // Use the passed homeScreenContext if available, otherwise fallback to current context
    final targetContext = homeScreenContext ?? context;
    return showDialog<void>(
      context: targetContext, // Use the appropriate context for the dialog
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Reset State?',
              style: TextStyle(
                  color: Theme.of(targetContext).colorScheme.onSurface)),
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
                // Assuming HygieneProvider is also available via Provider
                try {
                  final pointsService = targetContext.read<PointsService>();
                  final hygieneProvider = targetContext
                      .read<HygieneProvider>(); // Need HygieneProvider too
                  pointsService.resetData();
                  hygieneProvider.resetDebugState();
                  print("DEBUG: State reset triggered from ModernHeader.");
                } catch (e) {
                  print("Error accessing providers for reset: $e");
                  // Optionally show an error message
                }

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
    final targetContext = homeScreenContext ?? context;
    final pointsService = targetContext.read<PointsService>();
    final streakController =
        TextEditingController(text: pointsService.streak.toString());

    return showDialog<void>(
      context: targetContext,
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
                  print(
                      "DEBUG: Attempting to set streak to $newStreak from ModernHeader");
                } else {
                  // Optional: Show a snackbar for invalid input
                  ScaffoldMessenger.of(targetContext).showSnackBar(
                    // Use targetContext
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

  // --- Helper for Debug Notification Actions (requires context) ---
  void _checkPendingNotifications(BuildContext context) async {
    final targetContext = homeScreenContext ?? context;
    try {
      final notificationService = targetContext.read<NotificationService>();
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
      // Check if the context is still valid before showing ScaffoldMessenger
      if (targetContext.mounted) {
        ScaffoldMessenger.of(targetContext).showSnackBar(
          const SnackBar(
              content: Text('Pending notifications printed to console.')),
        );
      }
    } catch (e) {
      print("ERROR checking pending notifications: $e");
      if (targetContext.mounted) {
        ScaffoldMessenger.of(targetContext).showSnackBar(
          SnackBar(content: Text('Error checking notifications: $e')),
        );
      }
    }
  }

  void _sendTestNotification(BuildContext context) {
    final targetContext = homeScreenContext ?? context;
    try {
      final notificationService = targetContext.read<NotificationService>();
      notificationService.scheduleTestNotification();
      if (targetContext.mounted) {
        ScaffoldMessenger.of(targetContext).showSnackBar(
          const SnackBar(content: Text('Test notification scheduled for 5s.')),
        );
      }
    } catch (e) {
      print("ERROR sending test notification: $e");
      if (targetContext.mounted) {
        ScaffoldMessenger.of(targetContext).showSnackBar(
          SnackBar(content: Text('Error sending test notification: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use watch here to react to changes in PointsService
    final pointsService = context.watch<PointsService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Important to prevent vertical expansion
      children: [
        // --- Re-add Header with Title and Quote ---
        Padding(
          padding: const EdgeInsets.only(
              top: 16.0, left: 20.0, right: 20.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'RizzCheck', // Keep generic title for now
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 4),
              // Daily Quote
              if (dailyQuote.isNotEmpty) // Conditionally display quote
                Text(
                  dailyQuote,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                  softWrap: true,
                ),
            ],
          ),
        ),

        // --- Points/Streak Container ---
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            // Replace solid color with a gradient
            // color: Theme.of(context).colorScheme.primaryContainer,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary, // Start color
                Theme.of(context)
                    .colorScheme
                    .secondary, // End color (or primaryVariant, etc.)
                // Example using variations:
                // Theme.of(context).colorScheme.primary,
                // Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                // Adjust shadow color if needed to complement gradient
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 6.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Column for Points and Streak on the left
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          // Ensure icon color contrasts with gradient
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Points: ${pointsService.points}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // Ensure text color contrasts with gradient
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          // Ensure icon color contrasts with gradient
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Streak: ${pointsService.streak}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // Ensure text color contrasts with gradient
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Conditionally display Debug Action Buttons
              if (showDebugActions)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset State (Debug)',
                      iconSize: 20,
                      // Ensure icon color contrasts with gradient
                      color: Theme.of(context).colorScheme.onPrimary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        _showResetConfirmationDialog(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.star),
                      tooltip: 'Set Streak (Debug)',
                      iconSize: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        _showSetStreakDialog(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.list_alt),
                      tooltip: 'Check Pending Notifications (Debug)',
                      iconSize: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _checkPendingNotifications(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_active),
                      tooltip: 'Send Test Notification (Debug)',
                      iconSize: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _sendTestNotification(context),
                    ),
                  ],
                )
              else // Ensure the Row doesn't take up space if actions are hidden
                const SizedBox.shrink(),
            ],
          ),
        ),
        // Divider
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Divider(height: 1, thickness: 1),
        ),
      ],
    );
  }
}

// Ensure HygieneProvider is imported if needed for reset functionality
// (May require adding '../providers/hygiene_provider.dart')
// import '../providers/hygiene_provider.dart';
