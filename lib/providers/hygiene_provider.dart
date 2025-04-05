import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hygiene_task.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import '../services/notification_service.dart'; // Import
import 'package:provider/provider.dart';
import '../services/points_service.dart';

class HygieneProvider with ChangeNotifier {
  List<HygieneTask> _tasks = [];
  final SharedPreferences _prefs;
  final NotificationService _notificationService; // Add this
  final PointsService _pointsService;

  // Key to store the last date tasks were reset
  static const String _lastResetDateKey = 'last_reset_date';

  HygieneProvider(this._prefs, this._notificationService, this._pointsService) {
    _loadTasks();
  }

  // Initialize method to handle async loading and resetting
  Future<void> initialize() async {
    _loadTasks(); // Load existing tasks first

    // Check if reset is needed
    final todayString = _formatDate(DateTime.now());
    final lastResetDateString = _prefs.getString(_lastResetDateKey);

    if (lastResetDateString == null || lastResetDateString != todayString) {
      // If it's a new day or first launch, reset completion status
      bool wasReset = _resetAllTasksCompletion();
      if (wasReset) {
        await _prefs.setString(
            _lastResetDateKey, todayString); // Store today's date as last reset
        // No need to save tasks here if resetAllTasks already saved
      }
    }

    _ensureDefaultTasks(); // Ensure default tasks exist if list is empty

    // Save tasks if defaults were added OR if reset happened without save
    // _saveTasks(); // Let's rethink if save is needed here, reset and ensureDefaults handle it.

    notifyListeners(); // Notify after all setup is done
  }

  List<HygieneTask> get tasks =>
      _tasks.where((task) => !task.isCompleted).toList();
  List<HygieneTask> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  List<HygieneTask> get todaysTasks {
    final today = DateTime.now().weekday;
    return _tasks.where((task) => task.daysOfWeek.contains(today)).toList();
  }

  // Renamed from _initializeDefaultTasks
  void _ensureDefaultTasks() {
    if (_tasks.isEmpty) {
      print("Initializing default tasks..."); // Debug print
      _tasks = [
        HygieneTask(
          id: '1',
          title: 'Brush Your Teeth',
          description:
              'Scrub those chompers! Morning and night keeps the fuzz away.',
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Monday to Sunday
        ),
        HygieneTask(
          id: '2',
          title: 'Put on Deodorant',
          description:
              'Swipe right, swipe left. Keep the stink monsters locked up.',
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        ),
        HygieneTask(
          id: '3',
          title: 'Put on Clean Undies',
          description: 'Nobody likes skid row. Grab a clean pair!',
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        ),
        HygieneTask(
          id: '4',
          title: 'Operation Scrub Down',
          description:
              'Soap up everywhere! Don\'t forget behind the ears & remember to scrub your bag!',
          daysOfWeek: [2, 4, 6], // Tuesday, Thursday, Saturday
        ),
      ];
      _saveTasks(); // Save immediately after adding defaults
    } else {
      print(
          "Tasks already exist, default tasks not initialized."); // Debug print
    }
  }

  void _loadTasks() {
    final tasksJson = _prefs.getString('tasks');
    if (tasksJson != null && tasksJson.isNotEmpty) {
      // Check if JSON is valid
      try {
        final List<dynamic> decodedTasks = json.decode(tasksJson);
        // Successfully decoded, update the list
        _tasks =
            decodedTasks.map((task) => HygieneTask.fromJson(task)).toList();
        print("Loaded ${_tasks.length} tasks from storage.");
      } catch (e) {
        print(
            "Error decoding tasks: $e. Retaining previous in-memory tasks if any.");
        // If decoding fails but _tasks already has data (from current session),
        // don't clear it. Only clear if _tasks was empty to begin with.
        if (_tasks.isEmpty) {
          _tasks = [];
        }
      }
    } else {
      print("No tasks found in storage.");
      // No tasks stored, ensure the list is empty.
      _tasks = [];
    }
    // Don't notify here, let initialize() do it once at the end
  }

  void _saveTasks() {
    final tasksJson = json.encode(_tasks.map((task) => task.toJson()).toList());
    _prefs.setString('tasks', tasksJson);
    print("Saved ${_tasks.length} tasks to storage."); // Debug print
    // Don't notify here, let initialize() / toggle do it
  }

  Future<void> _checkAndHandleCompletion() async {
    // Check if all tasks for today are complete
    final todaysIncompleteTasks =
        todaysTasks.where((task) => !task.isCompleted).toList();

    if (todaysIncompleteTasks.isEmpty) {
      // Check if we haven't already processed completion for today
      final todayString = _formatDate(DateTime.now());
      // Use a more descriptive key
      const String lastCompletionProcessedKey =
          'last_completion_processed_date';
      final lastProcessedDate = _prefs.getString(lastCompletionProcessedKey);

      if (lastProcessedDate != todayString) {
        print(
            "DEBUG: All tasks complete! Processing completion for $todayString...");

        // Mark completion processed for today
        await _prefs.setString(lastCompletionProcessedKey, todayString);

        // Cancel the urgent notification
        await _notificationService
            .cancelNotification(NotificationService.urgentReminderId);

        // Award points and mark date directly here
        await _pointsService.awardDailyCompletionPoints();
        await _pointsService.markDateAsCompleted(DateTime.now());
      } else {
        print("DEBUG: Completion already processed for today ($todayString).");
      }
    }
  }

  // Modify toggleTaskCompletion to call the check
  void toggleTaskCompletion(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      // Toggle completion status
      task.isCompleted = !task.isCompleted;
      print(
          "DEBUG: Toggled task '${task.title}' to ${task.isCompleted ? 'Complete' : 'Incomplete'}");

      // Record the date of *this specific task* completion
      if (task.isCompleted) {
        _pointsService.recordTaskCompletionDate(DateTime.now());
      }
      // If needed, add logic here to handle un-completing a task (e.g., remove date?)

      notifyListeners(); // Notify UI of the toggle change

      // Check if ALL tasks are now completed AFTER notifying about the toggle
      if (task.isCompleted && _areAllTasksCompleted()) {
        print(
            "DEBUG: All tasks completed for the day! Recording daily completion.");
        _pointsService.recordDailyCompletion(DateTime.now());
        // Optional: Add a delay before resetting tasks for the next day?
        // Or handle reset elsewhere (e.g., start of day check)
      }
    }
  }

  // Helper method to check if all tasks are completed
  bool _areAllTasksCompleted() {
    // Use .every() for a concise check
    return _tasks.every((task) => task.isCompleted);
  }

  // Renamed from resetDailyTasks
  // Returns true if any task was actually reset
  bool _resetAllTasksCompletion() {
    bool changed = false;
    print("Resetting task completion status..."); // Debug print
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isCompleted) {
        _tasks[i].isCompleted = false;
        changed = true;
      }
    }
    if (changed) {
      _saveTasks(); // Save only if something changed
    }
    print("Task reset finished. Changed: $changed"); // Debug print
    return changed;
  }

  // Reset for debugging purposes
  Future<void> resetDebugState() async {
    print("DEBUG: Resetting HygieneProvider state...");
    bool changed = false;
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isCompleted) {
        _tasks[i].isCompleted = false;
        changed = true;
      }
    }
    await _prefs.remove(_lastResetDateKey);
    // Reset the completion processed marker too
    await _prefs.remove('last_completion_processed_date');
    print("DEBUG: Cleared last reset date key and completion marker.");

    if (changed) {
      _saveTasks();
    }

    _tasks.clear();
    _ensureDefaultTasks();

    notifyListeners();
    print("DEBUG: HygieneProvider reset complete.");
    // Don't need to call _checkAndHandleCompletion here,
    // as tasks are reset and the marker is cleared.
  }

  // Helper to format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
