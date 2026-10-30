import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';


class StatisticsScreen extends StatelessWidget {
  final List<Habit> habits;

  const StatisticsScreen({super.key, required this.habits});

  int get _totalCompletedCount {
    int total = 0;
    for (final h in habits) {
      total += h.completedDates.length;
    }
    return total;
  }

  int get _currentBestStreak {
    if (habits.isEmpty) return 0;
    int maxStreak = 0;
    for (final h in habits) {
      final s = h.calculateCurrentStreak();
      if (s > maxStreak) maxStreak = s;
    }
    return maxStreak;
  }

  int get _allTimeBestStreak {
    if (habits.isEmpty) return 0;
    int maxStreak = 0;
    for (final h in habits) {
      final s = h.calculateBestStreak();
      if (s > maxStreak) maxStreak = s;
    }
    return maxStreak;
  }

  /// Calculates completion rates for the last 7 days (ending today).
  List<_DayActivity> _getWeeklyData() {
    final now = DateTime.now();
    final List<_DayActivity> days = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = Habit.dateToDayKey(date);
      final dayName = DateFormat('E').format(date); // e.g. "Mon"

      int completedOnDate = 0;
      for (final h in habits) {
        if (h.isCompletedOn(dateKey)) {
          completedOnDate++;
        }
      }

      final rate = habits.isEmpty ? 0.0 : (completedOnDate / habits.length);
      days.add(_DayActivity(
        dayLabel: dayName,
        dateKey: dateKey,
        isToday: i == 0,
        completionRate: rate.clamp(0.0, 1.0),
        completedCount: completedOnDate,
      ));
    }
    return days;
  }

  int _calculateWeeklyAverage(List<_DayActivity> days) {
    if (days.isEmpty || habits.isEmpty) return 0;
    double sum = 0;
    for (final d in days) {
      sum += d.completionRate;
    }
    return ((sum / days.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _getWeeklyData();
    final weeklyAverage = _calculateWeeklyAverage(weeklyData);

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
                'Performance Analytics',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Real-time data driven by your daily consistency',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20.0),

              // 1. Top Metrics 2x2 Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Weekly Rate',
                      value: '$weeklyAverage%',
                      icon: Icons.trending_up_rounded,
                      color: AppTheme.cyanAccent,
                      subtitle: 'Last 7 days avg',
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Check-ins',
                      value: '$_totalCompletedCount',
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.emeraldSuccess,
                      subtitle: 'All-time habits done',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Current Streak',
                      value: '$_currentBestStreak d',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF97316),
                      subtitle: 'Active daily run',
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Best Streak',
                      value: '$_allTimeBestStreak d',
                      icon: Icons.emoji_events_rounded,
                      color: AppTheme.amberWarning,
                      subtitle: 'Personal record',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24.0),

              // 2. Weekly Activity Bar Chart
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weekly Activity',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.violetPrimary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text(
                            'Past 7 Days',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.violetPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22.0),

                    // Bar Chart Row
                    SizedBox(
                      height: 140.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weeklyData.map((d) {
                          return _buildBarColumn(d);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // 3. Habit-wise Completion Breakdown
              const Text(
                'Habit Performance Breakdown',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12.0),

              if (habits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Text(
                    'No habits registered yet.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              else
                ...habits.map((habit) {
                  final streak = habit.calculateCurrentStreak();
                  final completions = habit.completedDates.length;
                  final rate = habits.isEmpty
                      ? 0.0
                      : (completions / 30).clamp(0.0, 1.0); // 30-day index

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: habit.color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(
                                habit.iconData,
                                color: habit.color,
                                size: 18.0,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  Text(
                                    '${habit.category} • $completions check-ins',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (streak > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 3.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  '🔥 $streak d',
                                  style: const TextStyle(
                                    color: Color(0xFFFB923C),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: LinearProgressIndicator(
                            value: rate,
                            minHeight: 6.0,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              habit.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16.0),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(_DayActivity day) {
    const double maxBarHeight = 90.0;
    final double barHeight = (day.completionRate * maxBarHeight).clamp(6.0, maxBarHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Percentage label above bar
        Text(
          '${(day.completionRate * 100).round()}%',
          style: TextStyle(
            color: day.isToday ? AppTheme.cyanAccent : AppTheme.textMuted,
            fontSize: 10.0,
            fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6.0),

        // Animated glowing bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          width: 26.0,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: day.isToday
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: [
                      AppTheme.violetPrimary.withValues(alpha: 0.6),
                      AppTheme.indigoAccent.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(8.0),
            border: day.isToday
                ? Border.all(color: AppTheme.cyanAccent, width: 1.5)
                : null,
            boxShadow: day.isToday
                ? [
                    BoxShadow(
                      color: AppTheme.violetPrimary.withValues(alpha: 0.45),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8.0),

        // Day label
        Text(
          day.dayLabel,
          style: TextStyle(
            color: day.isToday ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 11.5,
            fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DayActivity {
  final String dayLabel;
  final String dateKey;
  final bool isToday;
  final double completionRate;
  final int completedCount;

  _DayActivity({
    required this.dayLabel,
    required this.dateKey,
    required this.isToday,
    required this.completionRate,
    required this.completedCount,
  });
}
