import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PointsService with ChangeNotifier {
  // Point system keys
  static const String _pointsKey = 'points';
  static const String _streakKey = 'streak';
  static const String _lastCompletionDateKey = 'last_completion_date';
  static const String _completedDatesKey = 'completed_dates';
  // REMOVED: Purchase status keys
  // static const String _driveInPurchasedKey = 'drive_in_purchased';
  // static const String _battingCagePurchasedKey = 'batting_cage_purchased';
  // static const String _sodaPurchasedKey = 'soda_purchased';
  // static const String _screenTimePurchasedKey = 'screen_time_purchased';
  // Remove Theme keys
  // static const String _selectedThemeIdKey = 'selected_theme_id';
  // static const String _unlockedThemeIdsKey = 'unlocked_theme_ids';
  static const List<int> _streakMilestones = [3, 7, 14, 30];

  int _points = 50;
  int _streak = 0;
  DateTime? _lastCompletionDate;
  Set<String> _completedDates = {};
  // REMOVED: Purchase status state variables
  // bool _driveInPurchased = false;
  // bool _battingCagePurchased = false;
  // bool _sodaPurchased = false;
  // bool _screenTimePurchased = false;

  int? achievedMilestone;

  PointsService() {
    loadPointsData();
  }

  // --- Getters ---
  int get points => _points;
  int get streak => _streak;
  DateTime? get lastCompletionDate => _lastCompletionDate;
  Set<String> get completedDates => _completedDates;
  // REMOVED: Purchase status getters
  // bool get isDriveInPurchased => _driveInPurchased;
  // bool get isBattingCagePurchased => _battingCagePurchased;
  // bool get isSodaPurchased => _sodaPurchased;
  // bool get isScreenTimePurchased => _screenTimePurchased;

  // --- Data Loading and Saving ---
  Future<void> loadPointsData() async {
    final prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt(_pointsKey) ?? 0;
    _streak = prefs.getInt(_streakKey) ?? 0;
    final lastDateString = prefs.getString(_lastCompletionDateKey);
    if (lastDateString != null) {
      _lastCompletionDate = DateTime.parse(lastDateString);
    }
    final loadedDates = prefs.getStringList(_completedDatesKey) ?? [];
    _completedDates = loadedDates.toSet();

    print("DEBUG: Loaded $_points points.");
    print("DEBUG: Loaded $_streak day streak.");
    print("DEBUG: Last completion date: $_lastCompletionDate");
    print("DEBUG: Loaded ${_completedDates.length} completed dates.");

    // REMOVED: Loading purchase statuses
    // _driveInPurchased = prefs.getBool(_driveInPurchasedKey) ?? false;
    // print("DEBUG: Drive-In purchased status: $_driveInPurchased");
    // _battingCagePurchased = prefs.getBool(_battingCagePurchasedKey) ?? false;
    // print("DEBUG: Batting Cage purchased status: $_battingCagePurchased");
    // _sodaPurchased = prefs.getBool(_sodaPurchasedKey) ?? false;
    // print("DEBUG: Soda purchased status: $_sodaPurchased");
    // _screenTimePurchased = prefs.getBool(_screenTimePurchasedKey) ?? false;
    // print("DEBUG: Screen Time purchased status: $_screenTimePurchased");

    achievedMilestone = null; // Reset milestone check on load
    notifyListeners();
  }

  // Helper to save points and streak
  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _points);
    await prefs.setInt(_streakKey, _streak);
    if (_lastCompletionDate != null) {
      await prefs.setString(
          _lastCompletionDateKey, _lastCompletionDate!.toIso8601String());
    }
    await prefs.setStringList(_completedDatesKey, _completedDates.toList());
    print("DEBUG: Saved points ($_points) and streak ($_streak)");
  }

  // --- Point Management ---
  Future<void> addPoints(int amount, {bool isCompletionBonus = false}) async {
    // This method is now primarily for manual adjustments or non-task bonuses
    // The daily completion bonus is handled in recordDailyCompletion
    _points += amount;
    print("DEBUG: Added $amount points (manual/other). New total: $_points");
    // Removing milestone check here, it belongs with streak updates
    // if (isCompletionBonus) { ... }
    await _savePoints();
    notifyListeners();
  }

  // Renamed to reflect its new purpose: just records the date
  Future<void> recordTaskCompletionDate(DateTime completionTime) async {
    // Only records the date, does not affect points or streak directly.
    final dateString = DateFormat('yyyy-MM-dd').format(completionTime);
    _completedDates.add(dateString);
    print("DEBUG: Recorded task completion date: $dateString");
    await _savePoints(); // Save the updated set of dates
    // No notifyListeners needed here usually, as this doesn't change UI points/streak
  }

  // NEW METHOD: Handles daily completion logic (streak, points)
  Future<void> recordDailyCompletion(DateTime completionTime) async {
    print("DEBUG: Attempting to record daily completion...");
    // Award daily points
    _points += 50; // Daily completion bonus
    print("DEBUG: Awarded 50 points for daily completion. New total: $_points");

    // Streak Logic
    bool streakContinued = false;
    if (_lastCompletionDate != null) {
      final difference = completionTime.difference(_lastCompletionDate!).inDays;
      final isSameDay = DateFormat('yyyy-MM-dd').format(completionTime) ==
          DateFormat('yyyy-MM-dd').format(_lastCompletionDate!);

      if (!isSameDay) {
        // Ensure it's not the same day
        if (difference == 1 ||
            (difference == 0 &&
                completionTime.day != _lastCompletionDate!.day)) {
          // Completed on the next calendar day
          _streak++;
          streakContinued = true;
          print("DEBUG: Streak continued! New streak: $_streak");
        } else if (difference > 1) {
          // Missed one or more days
          _streak = 1; // Reset to 1 for today's completion
          print("DEBUG: Streak broken. Resetting to 1.");
        }
        // If difference is 0 but not same day (e.g. <24hrs but across midnight), handled above.
      } else {
        print("DEBUG: Daily completion already recorded for today.");
        // Potentially revert the +50 points if desired? For now, let it add.
        // Alternatively, HygieneProvider could check if already called today.
      }
    } else {
      // First completion ever
      _streak = 1;
      print("DEBUG: First completion recorded. Streak set to 1.");
    }

    // Update last completion date only if streak was updated or started
    if (streakContinued || _streak == 1) {
      _lastCompletionDate = completionTime;
      print("DEBUG: Updated last completion date: $_lastCompletionDate");
    }

    // Check for streak milestones AFTER potentially updating streak
    if (_streakMilestones.contains(_streak)) {
      achievedMilestone = _streak;
      print("DEBUG: Achieved milestone: $_streak days!");
      // Maybe add bonus points for milestones here too?
      // addPoints(100); // Example: 100 bonus points for milestone
    } else {
      achievedMilestone = null; // Ensure it's null if not a milestone
    }

    await _savePoints();
    notifyListeners(); // Notify UI about point and potential streak changes
  }

  // New method to mark a date as fully completed
  Future<void> markDateAsCompleted(DateTime date) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    // Add the date string to the set (duplicates are automatically handled)
    bool added = _completedDates.add(dateString);

    if (added) {
      // Only save if a new date was actually added
      print("DEBUG: Marking $dateString as completed.");
      final prefs = await SharedPreferences.getInstance();
      // Convert Set back to List for saving
      await prefs.setStringList(_completedDatesKey, _completedDates.toList());
      notifyListeners(); // Notify listeners about the change in completed dates
    } else {
      print("DEBUG: Date $dateString was already marked as completed.");
    }
  }

  // Method to get the set of completed dates (for the calendar)
  Set<String> getCompletedDates() {
    return _completedDates;
  }

  // New method to award points for completing all daily tasks
  Future<void> awardDailyCompletionPoints() async {
    const int dailyBonus = 50; // Points awarded for finishing the day
    print("DEBUG: Awarding $dailyBonus daily completion points.");
    _points += dailyBonus;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _points);
    notifyListeners(); // Notify UI about point change
  }

  // Method for UI to clear the milestone flag
  void clearAchievedMilestone() {
    if (achievedMilestone != null) {
      achievedMilestone = null;
      // Optionally notify listeners if UI needs to react to the clear itself
      // notifyListeners();
    }
  }

  Future<void> setStreakDebug(int newStreak) async {
    if (newStreak < 0) return;
    final prefs = await SharedPreferences.getInstance();
    _streak = newStreak;
    if (_streak > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      _lastCompletionDate = today.subtract(const Duration(days: 1));
      await prefs.setString(
          _lastCompletionDateKey, _lastCompletionDate!.toIso8601String());
    } else {
      _lastCompletionDate = null;
      await prefs.remove(_lastCompletionDateKey);
    }
    await prefs.setInt(_streakKey, _streak);
    achievedMilestone = null;
    print("DEBUG: Streak set to $_streak");
    notifyListeners();
  }

  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    _points = 0;
    _streak = 0;
    _lastCompletionDate = null;
    _completedDates.clear();
    // REMOVED: Resetting purchase statuses
    // _driveInPurchased = false;
    // _battingCagePurchased = false;
    // _sodaPurchased = false;
    // _screenTimePurchased = false;
    await prefs.remove(_pointsKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_lastCompletionDateKey);
    await prefs.remove(_completedDatesKey);
    // REMOVED: Removing purchase status keys
    // await prefs.remove(_driveInPurchasedKey);
    // await prefs.remove(_battingCagePurchasedKey);
    // await prefs.remove(_sodaPurchasedKey);
    // await prefs.remove(_screenTimePurchasedKey);
    achievedMilestone = null;
    notifyListeners();
    print("DEBUG: Data Reset");
  }

  // Helper to check if a date is yesterday or today (potentially unused now?)
  /*
  bool _isYesterdayOrToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDay = DateTime(date.year, date.month, date.day);
    return checkDay == today || checkDay == yesterday;
  }
  */

  // --- REMOVE Theme Methods ---
  // bool isThemeUnlocked(String themeId) { ... }
  // String getSelectedThemeId() { ... }
  // Future<bool> unlockTheme(String themeId) async { ... }
  // Future<void> selectTheme(String themeId) async { ... }
  // --- End REMOVE Theme Methods ---

  // --- REMOVE Monthly Completion Logic ---
  // int _getDaysInMonth(int year, int month) { ... }
  // bool checkMonthlyCompletion(int year, int month) { ... }
  // --- End REMOVE Monthly Completion Logic ---

  // --- Point Spending ---
  Future<bool> spendPoints(int amount) async {
    if (_points >= amount) {
      _points -= amount;
      await _savePoints(); // Save the new point total
      notifyListeners(); // Notify listeners about point change
      print("DEBUG: Spent $amount points. Remaining: $_points");
      return true;
    } else {
      print("DEBUG: Insufficient points to spend $amount. Have: $_points");
      return false;
    }
  }
  // --- End Point Spending ---

  // REMOVED: mark...Purchased() methods
  /*
  Future<void> markDriveInPurchased() async { ... }
  Future<void> markBattingCagePurchased() async { ... }
  Future<void> markSodaPurchased() async { ... }
  Future<void> markScreenTimePurchased() async { ... }
  */
}
