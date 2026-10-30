import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

/// Storage service providing persistent data management for habits and user preferences.
class HabitStorage {
  static const String _habitsKey = 'daily_habits_list_v2';
  static const String _initKey = 'has_initialized_defaults_v2';
  static const String _userNameKey = 'user_profile_name_v2';
  static const String _notificationKey = 'setting_notifications_v2';
  static const String _soundKey = 'setting_sounds_v2';

  /// Loads habits from storage.
  ///
  /// On first application launch, pre-seeds the list with default habits
  /// so the user immediately experiences a fully populated, gorgeous interface.
  Future<List<Habit>> loadHabits() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final bool hasInitialized = prefs.getBool(_initKey) ?? false;
      final String? habitsJson = prefs.getString(_habitsKey);

      // Pre-seed default habits on very first launch
      if (!hasInitialized || habitsJson == null || habitsJson.trim().isEmpty) {
        final List<Habit> defaults = Habit.defaultHabits;
        await saveHabits(defaults);
        await prefs.setBool(_initKey, true);
        return defaults;
      }

      final dynamic decoded = jsonDecode(habitsJson);
      if (decoded is List) {
        final List<Habit> loaded = decoded
            .map((item) => Habit.fromJson(item as Map<String, dynamic>))
            .toList();
        return loaded;
      }

      return [];
    } catch (error, stackTrace) {
      debugPrint('Error loading habits from storage: $error\n$stackTrace');
      return Habit.defaultHabits;
    }
  }

  /// Persists the list of habits to local storage.
  Future<bool> saveHabits(List<Habit> habits) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> maps =
          habits.map((h) => h.toJson()).toList();
      final String jsonString = jsonEncode(maps);
      await prefs.setBool(_initKey, true);
      return await prefs.setString(_habitsKey, jsonString);
    } catch (error, stackTrace) {
      debugPrint('Error saving habits: $error\n$stackTrace');
      return false;
    }
  }

  /// Retrieves the saved user profile name.
  Future<String> getUserName() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey) ?? 'Habit Builder';
    } catch (_) {
      return 'Habit Builder';
    }
  }

  /// Saves the user profile name.
  Future<bool> saveUserName(String name) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userNameKey, name);
    } catch (_) {
      return false;
    }
  }

  /// Retrieves notification preference.
  Future<bool> getNotificationEnabled() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Saves notification preference.
  Future<bool> saveNotificationEnabled(bool enabled) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_notificationKey, enabled);
    } catch (_) {
      return false;
    }
  }

  /// Retrieves sound/haptics preference.
  Future<bool> getSoundEnabled() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_soundKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Saves sound/haptics preference.
  Future<bool> saveSoundEnabled(bool enabled) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_soundKey, enabled);
    } catch (_) {
      return false;
    }
  }

  /// Resets all habits to original default state.
  Future<List<Habit>> resetToDefaults() async {
    final List<Habit> defaults = Habit.defaultHabits;
    await saveHabits(defaults);
    return defaults;
  }

  /// Clears habit storage completely.
  Future<bool> clearAllHabits() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_habitsKey);
    } catch (_) {
      return false;
    }
  }
}
