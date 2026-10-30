import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/add_habit_sheet.dart';

/// The primary Home Dashboard of the Habit Tracker.
///
/// Features:
/// - Dynamic time-based greeting ("Good Morning", etc.) and formatted date.
/// - Glowing avatar & notification bell.
/// - Large gradient progress card with animated circular completion ring.
/// - Filter chips (All, Pending, Completed).
/// - Interactive habit cards with completion micro-animations.
/// - Full creation, editing, and deletion with confirmation.
class HomeScreen extends StatefulWidget {
  final List<Habit> habits;
  final String userName;
  final Function(Habit) onToggleHabit;
  final Function(Habit) onAddHabit;
  final Function(Habit) onUpdateHabit;
  final Function(String) onDeleteHabit;
  final VoidCallback onNavigateToProfile;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.userName,
    required this.onToggleHabit,
    required this.onAddHabit,
    required this.onUpdateHabit,
    required this.onDeleteHabit,
    required this.onNavigateToProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeFilter = 'All'; // 'All', 'Pending', 'Done'

  String get _todayDateKey => Habit.dateToDayKey(DateTime.now());

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int get _completedTodayCount {
    return widget.habits.where((h) => h.isCompletedOn(_todayDateKey)).length;
  }

  List<Habit> get _filteredHabits {
    final today = _todayDateKey;
    switch (_activeFilter) {
      case 'Pending':
        return widget.habits.where((h) => !h.isCompletedOn(today)).toList();
      case 'Done':
        return widget.habits.where((h) => h.isCompletedOn(today)).toList();
      default:
        return widget.habits;
    }
  }

  void _openAddHabitSheet([Habit? habitToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddHabitSheet(
          existingHabit: habitToEdit,
          onSave: (habit) {
            if (habitToEdit != null) {
              widget.onUpdateHabit(habit);
            } else {
              widget.onAddHabit(habit);
            }
          },
        );
      },
    );
  }

  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.0),
            side: const BorderSide(color: AppTheme.borderGlass),
          ),
          title: const Text(
            'Delete Habit?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to remove "${habit.title}"?\nYour past streak and completion history will be erased.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14.0,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.roseDanger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleteHabit(habit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed "${habit.title}"'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.surfaceElevated,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEEE, MMM d').format(DateTime.now());
    final filtered = _filteredHabits;

    return Scaffold(
      backgroundColor: AppTheme.bgMidnight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12.0),
            // 1. Dashboard Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, ${widget.userName.split(' ').first}! 👋',
                        style: const TextStyle(
                          fontSize: 21.0,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Notification bell with micro badge
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.borderSubtle,
                            width: 1.0,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.textPrimary,
                            size: 20.0,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All daily reminders are on schedule! 🔔'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      // Profile Avatar
                      GestureDetector(
                        onTap: widget.onNavigateToProfile,
                        child: Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.subtleGlow,
                            border: Border.all(
                              color: AppTheme.cyanAccent.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.userName.isNotEmpty
                                  ? widget.userName[0].toUpperCase()
                                  : 'H',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14.0),

            // 2. Large Daily Progress Section
            ProgressCard(
              completedCount: _completedTodayCount,
              totalCount: widget.habits.length,
            ),

            const SizedBox(height: 10.0),

            // 3. Section Title & Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Today's Habits",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Text(
                          '${widget.habits.length}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.violetPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Filter Row
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: ['All', 'Pending', 'Done'].map((filter) {
                        final isSelected = _activeFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _activeFilter = filter);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.violetPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6.0),

            // 4. Scrollable Habit List or Empty State
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 90.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final habit = filtered[index];
                        return HabitCard(
                          key: ValueKey(habit.id),
                          habit: habit,
                          dateKey: _todayDateKey,
                          onToggle: () => widget.onToggleHabit(habit),
                          onEdit: () => _openAddHabitSheet(habit),
                          onDelete: () => _showDeleteDialog(habit),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Prominent Floating Action Button with Gradient and Glow
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.violetGlow,
          ),
          child: FloatingActionButton(
            heroTag: 'home_fab_add',
            onPressed: () => _openAddHabitSheet(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderGlass, width: 1.5),
                boxShadow: AppTheme.subtleGlow,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 40.0,
                color: AppTheme.cyanAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              _activeFilter == 'Done'
                  ? 'No completed habits yet'
                  : _activeFilter == 'Pending'
                      ? 'All caught up!'
                      : 'No habits added yet',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              _activeFilter == 'Done'
                  ? 'Check off your first habit to see it here.'
                  : _activeFilter == 'Pending'
                      ? 'Incredible job! You have conquered all habits today.'
                      : 'Tap the + button to build your first daily routine.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
