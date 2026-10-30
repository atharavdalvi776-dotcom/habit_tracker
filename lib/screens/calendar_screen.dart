import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';


class CalendarScreen extends StatefulWidget {
  final List<Habit> habits;
  final Function(Habit, String) onToggleForDate;

  const CalendarScreen({
    super.key,
    required this.habits,
    required this.onToggleForDate,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  int _getFirstWeekday(DateTime month) {
    // 1 is Monday in Dart DateTime
    return DateTime(month.year, month.month, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayKey = Habit.dateToDayKey(now);
    final selectedDateKey = Habit.dateToDayKey(_selectedDate);

    final monthTitle = DateFormat('MMMM yyyy').format(_displayedMonth);
    final daysInMonth = _getDaysInMonth(_displayedMonth);
    final firstWeekday = _getFirstWeekday(_displayedMonth);

    // Habits completed on selected date
    final completedOnSelected = widget.habits
        .where((h) => h.isCompletedOn(selectedDateKey))
        .length;

    return Scaffold(
      backgroundColor: AppTheme.bgMidnight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 14.0,
            bottom: 100.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Habit History',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Inspect daily completion and track your consistency',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 18.0),

              // Calendar Card Container
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    // Month Navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppTheme.textPrimary,
                          ),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          monthTitle,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.textPrimary,
                          ),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    // Weekday Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                        return SizedBox(
                          width: 36.0,
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10.0),

                    // Days Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (firstWeekday - 1) + daysInMonth,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6.0,
                        crossAxisSpacing: 6.0,
                      ),
                      itemBuilder: (context, index) {
                        // Offset for first day of month
                        if (index < firstWeekday - 1) {
                          return const SizedBox.shrink();
                        }

                        final dayNum = index - (firstWeekday - 2);
                        final date = DateTime(
                          _displayedMonth.year,
                          _displayedMonth.month,
                          dayNum,
                        );
                        final dateKey = Habit.dateToDayKey(date);

                        final isToday = dateKey == todayKey;
                        final isSelected = dateKey == selectedDateKey;

                        // Completion rate on this day
                        int completedCount = 0;
                        for (final h in widget.habits) {
                          if (h.isCompletedOn(dateKey)) {
                            completedCount++;
                          }
                        }

                        final bool hasCompletedAll =
                            widget.habits.isNotEmpty &&
                                completedCount == widget.habits.length;
                        final bool hasPartial =
                            completedCount > 0 && !hasCompletedAll;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = date);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.violetPrimary
                                  : isToday
                                      ? AppTheme.surfaceElevated
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.cyanAccent
                                    : isToday
                                        ? AppTheme.violetPrimary
                                        : Colors.transparent,
                                width: isSelected ? 1.6 : 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: isSelected || isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                            ? AppTheme.cyanAccent
                                            : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                // Dot indicator
                                if (hasCompletedAll)
                                  Container(
                                    width: 5.0,
                                    height: 5.0,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.emeraldSuccess,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else if (hasPartial)
                                  Container(
                                    width: 5.0,
                                    height: 5.0,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.violetPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
                                  const SizedBox(height: 5.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // Selected Date Summary Card
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            '$completedOnSelected of ${widget.habits.length} done',
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cyanAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),

                    // List of habits for this selected date
                    if (widget.habits.isEmpty)
                      const Text(
                        'No habits configured.',
                        style: TextStyle(color: AppTheme.textMuted),
                      )
                    else
                      ...widget.habits.map((habit) {
                        final isDone = habit.isCompletedOn(selectedDateKey);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              widget.onToggleForDate(habit, selectedDateKey);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 6.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isDone
                                        ? AppTheme.emeraldSuccess
                                        : AppTheme.textMuted,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Text(
                                      habit.title,
                                      style: TextStyle(
                                        color: isDone
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                        fontWeight: isDone
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: 14.0,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    habit.category,
                                    style: TextStyle(
                                      color: habit.color,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

