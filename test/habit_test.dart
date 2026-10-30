import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/habit_storage.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit initializes correctly with default values', () {
      final habit = Habit(
        id: '123',
        title: 'Drink 2L Water',
      );

      expect(habit.id, '123');
      expect(habit.title, 'Drink 2L Water');
      expect(habit.isCompleted, false);
      expect(habit.lastCompletedDate, isNull);
      expect(habit.createdAt, isNotNull);
    });

    test('dateToDayKey converts DateTime to YYYY-MM-DD format', () {
      final date = DateTime(2026, 10, 30);
      final key = Habit.dateToDayKey(date);
      expect(key, '2026-10-30');

      final dateWithSingleDigits = DateTime(2026, 5, 4);
      expect(Habit.dateToDayKey(dateWithSingleDigits), '2026-05-04');
    });

    test('toggleCompletion flips status and updates lastCompletedDate', () {
      final habit = Habit(id: '1', title: 'Exercise');
      const today = '2026-10-30';

      // 1. Mark complete
      habit.toggleCompletion(today);
      expect(habit.isCompletedOn(today), true);
      expect(habit.lastCompletedDate, today);

      // 2. Mark incomplete
      habit.toggleCompletion(today);
      expect(habit.isCompletedOn(today), false);
      expect(habit.lastCompletedDate, isNull);
    });

    test('Streak calculation works accurately across consecutive days', () {
      final now = DateTime(2026, 10, 30);
      final habit = Habit(
        id: 'streak_test',
        title: 'Daily Meditation',
        completedDates: [
          '2026-10-30',
          '2026-10-29',
          '2026-10-28',
        ],
      );

      expect(habit.calculateCurrentStreak(now), 3);
      expect(habit.calculateBestStreak(), 3);
    });

    test('JSON serialization and deserialization works correctly', () {
      final habit = Habit(
        id: '999',
        title: 'Walk 10,000 steps',
        description: 'Morning brisk walk',
        category: 'Fitness',
        colorValue: 0xFFF43F5E,
        completedDates: ['2026-10-30'],
        createdAt: DateTime(2026, 10, 30, 8, 30),
      );

      final jsonMap = habit.toJson();
      expect(jsonMap['id'], '999');
      expect(jsonMap['title'], 'Walk 10,000 steps');
      expect(jsonMap['description'], 'Morning brisk walk');
      expect(jsonMap['category'], 'Fitness');
      expect(jsonMap['colorValue'], 0xFFF43F5E);
      expect(jsonMap['completedDates'], ['2026-10-30']);

      final restoredHabit = Habit.fromJson(jsonMap);
      expect(restoredHabit.id, habit.id);
      expect(restoredHabit.title, habit.title);
      expect(restoredHabit.description, habit.description);
      expect(restoredHabit.category, habit.category);
      expect(restoredHabit.isCompletedOn('2026-10-30'), true);
    });
  });

  group('HabitStorage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadHabits initializes defaults on first run', () async {
      final storage = HabitStorage();
      final habits = await storage.loadHabits();
      expect(habits, isNotEmpty);
      expect(habits.length, 5); // 5 curated default habits
    });

    test('saveHabits persists habits and loadHabits restores them', () async {
      final storage = HabitStorage();
      final customHabits = [
        Habit(id: '1', title: 'Read 30 mins', completedDates: ['2026-10-30']),
        Habit(id: '2', title: 'Workout'),
      ];

      final saveResult = await storage.saveHabits(customHabits);
      expect(saveResult, true);

      final loadedHabits = await storage.loadHabits();
      expect(loadedHabits.length, 2);
      expect(loadedHabits[0].title, 'Read 30 mins');
      expect(loadedHabits[1].title, 'Workout');
    });
  });
}
