import 'package:flutter/material.dart';

/// Represents an individual daily habit with full visual styling and date history.
///
/// Supports:
/// - Categorization (e.g., Fitness, Learning, Health).
/// - Custom icons and accent colors.
/// - Complete completion history (`completedDates`) for calendar tracking and streaks.
/// - Dynamic streak calculation (current streak and best streak).
/// - Full backward compatibility with previous constructors and methods.
class Habit {
  /// Unique identifier.
  final String id;

  /// Habit name or title.
  String title;

  /// Short description or motivation.
  String description;

  /// Category name (e.g. "Fitness", "Learning", "Health").
  String category;

  /// CodePoint of the [IconData] representing this habit.
  int iconCodePoint;

  /// Hex color integer used for accent highlights.
  int colorValue;

  /// Complete list of calendar dates (in "YYYY-MM-DD" format) when this habit was completed.
  List<String> completedDates;

  /// Creation timestamp.
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'General',
    int? iconCodePoint,
    int? colorValue,
    List<String>? completedDates,
    bool? isCompleted,
    String? lastCompletedDate,
    DateTime? createdAt,
  })  : iconCodePoint = iconCodePoint ?? Icons.check_circle_rounded.codePoint,
        colorValue = colorValue ?? 0xFF8B5CF6,
        completedDates = completedDates ?? <String>[],
        createdAt = createdAt ?? DateTime.now() {
    // Backward compatibility initialization
    if (isCompleted == true && lastCompletedDate != null) {
      if (!this.completedDates.contains(lastCompletedDate)) {
        this.completedDates.add(lastCompletedDate);
      }
    }
  }

  /// Converts a [DateTime] into a standardized "YYYY-MM-DD" calendar key.
  static String dateToDayKey(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Returns the [IconData] for this habit.
  // ignore: non_const_argument_for_const_parameter
  IconData get iconData => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Returns the [Color] accent for this habit.
  Color get color => Color(colorValue);

  /// The most recent calendar date on which this habit was completed.
  String? get lastCompletedDate =>
      completedDates.isNotEmpty ? completedDates.last : null;

  /// Checks if the habit was completed on a specific calendar date ("YYYY-MM-DD").
  bool isCompletedOn(String dateString) {
    return completedDates.contains(dateString);
  }

  /// Checks if the habit is completed today.
  bool isCompletedToday([String? todayDateString]) {
    final today = todayDateString ?? dateToDayKey(DateTime.now());
    return isCompletedOn(today);
  }

  /// Legacy getter for backward compatibility.
  bool get isCompleted => isCompletedToday();

  /// Setter for backward compatibility.
  set isCompleted(bool val) {
    final today = dateToDayKey(DateTime.now());
    if (val) {
      if (!completedDates.contains(today)) completedDates.add(today);
    } else {
      completedDates.remove(today);
    }
  }

  /// Toggles the completion status for a given [dateString].
  ///
  /// Returns `true` if marked completed, `false` if marked incomplete.
  bool toggleCompletionForDate(String dateString) {
    if (completedDates.contains(dateString)) {
      completedDates.remove(dateString);
      return false;
    } else {
      completedDates.add(dateString);
      return true;
    }
  }

  /// Toggles the completion status for today.
  bool toggleCompletion([String? todayDateString]) {
    final today = todayDateString ?? dateToDayKey(DateTime.now());
    return toggleCompletionForDate(today);
  }

  /// Checks whether this habit needs to be reset for a new day.
  ///
  /// In this model, daily status is dynamically evaluated against calendar dates.
  /// If completed on a past day but not today, it naturally returns false for today.
  /// Returns `true` if a status change was detected.
  bool resetIfNewDay(String todayDateString) {
    // If not completed today, status for today is false.
    // If it had a previous day's completion, it doesn't leak into today.
    return !isCompletedOn(todayDateString);
  }

  /// Calculates the current streak (consecutive days of completion ending today or yesterday).
  int calculateCurrentStreak([DateTime? referenceDate]) {
    final DateTime now = referenceDate ?? DateTime.now();
    final String todayKey = dateToDayKey(now);
    final String yesterdayKey =
        dateToDayKey(now.subtract(const Duration(days: 1)));

    DateTime checkDate;
    if (completedDates.contains(todayKey)) {
      checkDate = now;
    } else if (completedDates.contains(yesterdayKey)) {
      checkDate = now.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    while (true) {
      final String key = dateToDayKey(checkDate);
      if (completedDates.contains(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Calculates the best (longest) streak across all completed dates.
  int calculateBestStreak() {
    if (completedDates.isEmpty) return 0;

    final Set<String> uniqueKeys = completedDates.toSet();
    final List<DateTime> sortedDates = uniqueKeys
        .map((k) {
          final parts = k.split('-');
          if (parts.length != 3) return null;
          return DateTime.tryParse(k);
        })
        .whereType<DateTime>()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (sortedDates.isEmpty) return 0;

    int maxStreak = 1;
    int currentRun = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final difference = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (difference == 1) {
        currentRun++;
        if (currentRun > maxStreak) {
          maxStreak = currentRun;
        }
      } else if (difference > 1) {
        currentRun = 1;
      }
    }

    return maxStreak;
  }

  /// Total number of times this habit was marked completed.
  int get totalCompletions => completedDates.length;

  /// Converts the habit to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'completedDates': completedDates,
      'createdAt': createdAt.toIso8601String(),
      // Legacy fields for backward compatibility
      'isCompleted': isCompletedToday(),
      'lastCompletedDate': completedDates.isNotEmpty ? completedDates.last : null,
    };
  }

  /// Restores a habit from a JSON map, handling legacy format gracefully.
  factory Habit.fromJson(Map<String, dynamic> json) {
    List<String> loadedDates = [];

    if (json['completedDates'] is List) {
      loadedDates = (json['completedDates'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['isCompleted'] == true && json['lastCompletedDate'] != null) {
      loadedDates = [json['lastCompletedDate'] as String];
    }

    return Habit(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled Habit',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      iconCodePoint: json['iconCodePoint'] as int? ?? Icons.check_circle_rounded.codePoint,
      colorValue: json['colorValue'] as int? ?? 0xFF8B5CF6,
      completedDates: loadedDates,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Creates a copy of this habit with modified attributes.
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? iconCodePoint,
    int? colorValue,
    List<String>? completedDates,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      completedDates: completedDates ?? List<String>.from(this.completedDates),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// List of 5 professionally designed default habits for new users.
  static List<Habit> get defaultHabits {
    final now = DateTime.now();
    final today = dateToDayKey(now);
    final yesterday = dateToDayKey(now.subtract(const Duration(days: 1)));
    final dayBeforeYesterday = dateToDayKey(now.subtract(const Duration(days: 2)));

    return [
      Habit(
        id: 'default_1',
        title: 'Morning Workout',
        description: '30 mins of strength or cardio training',
        category: 'Fitness',
        iconCodePoint: Icons.fitness_center_rounded.codePoint,
        colorValue: 0xFFF43F5E, // Coral Rose
        completedDates: [yesterday, dayBeforeYesterday],
      ),
      Habit(
        id: 'default_2',
        title: 'Read 20 Pages',
        description: 'Expand knowledge from a non-fiction book',
        category: 'Learning',
        iconCodePoint: Icons.menu_book_rounded.codePoint,
        colorValue: 0xFF8B5CF6, // Electric Violet
        completedDates: [today, yesterday, dayBeforeYesterday],
      ),
      Habit(
        id: 'default_3',
        title: 'Drink 2L Water',
        description: 'Stay refreshed & hydrated all day',
        category: 'Health',
        iconCodePoint: Icons.water_drop_rounded.codePoint,
        colorValue: 0xFF38BDF8, // Soft Cyan
        completedDates: [today, yesterday],
      ),
      Habit(
        id: 'default_4',
        title: 'Mindful Meditation',
        description: '10 mins of breathwork & mindfulness',
        category: 'Mindfulness',
        iconCodePoint: Icons.self_improvement_rounded.codePoint,
        colorValue: 0xFF10B981, // Emerald Green
        completedDates: [yesterday],
      ),
      Habit(
        id: 'default_5',
        title: 'Learn Something New',
        description: 'Code, language, or skill practice',
        category: 'Productivity',
        iconCodePoint: Icons.lightbulb_rounded.codePoint,
        colorValue: 0xFFF59E0B, // Amber Gold
        completedDates: [dayBeforeYesterday],
      ),
    ];
  }
}

/// Predefined category options with associated icons and colors.
class HabitCategoryOption {
  final String name;
  final IconData icon;
  final Color color;

  const HabitCategoryOption({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<HabitCategoryOption> all = [
    HabitCategoryOption(
      name: 'Fitness',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFF43F5E),
    ),
    HabitCategoryOption(
      name: 'Learning',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF8B5CF6),
    ),
    HabitCategoryOption(
      name: 'Health',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF38BDF8),
    ),
    HabitCategoryOption(
      name: 'Mindfulness',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF10B981),
    ),
    HabitCategoryOption(
      name: 'Productivity',
      icon: Icons.lightbulb_rounded,
      color: Color(0xFFF59E0B),
    ),
    HabitCategoryOption(
      name: 'Routine',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFEC4899),
    ),
  ];
}
