import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final HabitStorage _storage = HabitStorage();

  List<Habit> _habits = [];
  bool _isLoading = true;
  int _currentTabIndex = 0;

  String _userName = 'Habit Builder';
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-trigger rebuild on app resume to update today's dates & greetings
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadAllData() async {
    final loadedHabits = await _storage.loadHabits();
    final name = await _storage.getUserName();
    final notifs = await _storage.getNotificationEnabled();
    final sound = await _storage.getSoundEnabled();

    if (mounted) {
      setState(() {
        _habits = loadedHabits;
        _userName = name;
        _notificationsEnabled = notifs;
        _soundEnabled = sound;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHabits() async {
    await _storage.saveHabits(_habits);
    if (mounted) setState(() {});
  }

  void _handleToggleHabit(Habit habit) {
    setState(() {
      habit.toggleCompletion();
    });
    _saveHabits();
  }

  void _handleToggleForDate(Habit habit, String dateKey) {
    setState(() {
      habit.toggleCompletionForDate(dateKey);
    });
    _saveHabits();
  }

  void _handleAddHabit(Habit newHabit) {
    setState(() {
      _habits.add(newHabit);
    });
    _saveHabits();
  }

  void _handleUpdateHabit(Habit updatedHabit) {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      setState(() {
        _habits[index] = updatedHabit;
      });
      _saveHabits();
    }
  }

  void _handleDeleteHabit(String habitId) {
    setState(() {
      _habits.removeWhere((h) => h.id == habitId);
    });
    _saveHabits();
  }

  void _handleUpdateUserName(String name) async {
    setState(() => _userName = name);
    await _storage.saveUserName(name);
  }

  void _handleToggleNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    await _storage.saveNotificationEnabled(enabled);
  }

  void _handleToggleSound(bool enabled) async {
    setState(() => _soundEnabled = enabled);
    await _storage.saveSoundEnabled(enabled);
  }

  void _handleResetDefaults() async {
    final defaults = await _storage.resetToDefaults();
    setState(() {
      _habits = defaults;
    });
  }

  void _handleClearAll() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          title: const Text('Clear All Habits?'),
          content: const Text(
            'This action will permanently delete all your tracked habits and streaks.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.roseDanger,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _storage.clearAllHabits();
                setState(() {
                  _habits = [];
                });
              },
              child: const Text('Clear Everything'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgMidnight,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.violetPrimary,
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        habits: _habits,
        userName: _userName,
        onToggleHabit: _handleToggleHabit,
        onAddHabit: _handleAddHabit,
        onUpdateHabit: _handleUpdateHabit,
        onDeleteHabit: _handleDeleteHabit,
        onNavigateToProfile: () => setState(() => _currentTabIndex = 3),
      ),
      StatisticsScreen(habits: _habits),
      CalendarScreen(
        habits: _habits,
        onToggleForDate: _handleToggleForDate,
      ),
      ProfileScreen(
        habits: _habits,
        userName: _userName,
        notificationsEnabled: _notificationsEnabled,
        soundEnabled: _soundEnabled,
        onUpdateName: _handleUpdateUserName,
        onToggleNotifications: _handleToggleNotifications,
        onToggleSound: _handleToggleSound,
        onResetDefaults: _handleResetDefaults,
        onClearAll: _handleClearAll,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgMidnight,
      body: Stack(
        children: [
          // Current active screen
          IndexedStack(
            index: _currentTabIndex,
            children: screens,
          ),

          // Floating Glassmorphic Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ModernBottomNavigation(
              currentIndex: _currentTabIndex,
              onTabSelected: (index) {
                setState(() => _currentTabIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

