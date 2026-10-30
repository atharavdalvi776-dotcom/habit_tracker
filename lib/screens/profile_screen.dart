import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';


class ProfileScreen extends StatefulWidget {
  final List<Habit> habits;
  final String userName;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final ValueChanged<String> onUpdateName;
  final ValueChanged<bool> onToggleNotifications;
  final ValueChanged<bool> onToggleSound;
  final VoidCallback onResetDefaults;
  final VoidCallback onClearAll;

  const ProfileScreen({
    super.key,
    required this.habits,
    required this.userName,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.onUpdateName,
    required this.onToggleNotifications,
    required this.onToggleSound,
    required this.onResetDefaults,
    required this.onClearAll,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int get _totalCompleted {
    int sum = 0;
    for (final h in widget.habits) {
      sum += h.completedDates.length;
    }
    return sum;
  }

  int get _maxStreak {
    if (widget.habits.isEmpty) return 0;
    int maxS = 0;
    for (final h in widget.habits) {
      final s = h.calculateCurrentStreak();
      if (s > maxS) maxS = s;
    }
    return maxS;
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: widget.userName);
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
            'Edit Profile Name',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.bgMidnight,
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: const BorderSide(color: AppTheme.violetPrimary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.violetPrimary,
              ),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  widget.onUpdateName(name);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              // 1. Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 86.0,
                          height: 86.0,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.violetGlow,
                            border: Border.all(
                              color: AppTheme.cyanAccent,
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.userName.isNotEmpty
                                  ? widget.userName[0].toUpperCase()
                                  : 'H',
                              style: const TextStyle(
                                fontSize: 36.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showEditNameDialog,
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: const BoxDecoration(
                              color: AppTheme.cyanAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14.0,
                              color: AppTheme.bgMidnight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16.0,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: _showEditNameDialog,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.violetPrimary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppTheme.violetPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        '⭐ Consistency Champion',
                        style: TextStyle(
                          color: AppTheme.cyanAccent,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // 2. Lifetime Achievements Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      label: 'Habits Active',
                      value: '${widget.habits.length}',
                      icon: Icons.track_changes_rounded,
                      color: AppTheme.violetPrimary,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildStatTile(
                      label: 'Check-ins',
                      value: '$_totalCompleted',
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.emeraldSuccess,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _buildStatTile(
                      label: 'Best Streak',
                      value: '$_maxStreak d',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26.0),

              // 3. Application Preferences Section
              _buildSectionHeader('PREFERENCES & SETTINGS'),
              const SizedBox(height: 10.0),
              Material(
                color: AppTheme.surfaceCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Daily Reminders',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Receive morning & evening check-in alerts',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.0,
                        ),
                      ),
                      secondary: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppTheme.cyanAccent,
                      ),
                      activeThumbColor: AppTheme.violetPrimary,
                      value: widget.notificationsEnabled,
                      onChanged: widget.onToggleNotifications,
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 1.0),
                    SwitchListTile(
                      title: const Text(
                        'Sound & Micro-Haptics',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Feedback on habit completion',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.0,
                        ),
                      ),
                      secondary: const Icon(
                        Icons.vibration_rounded,
                        color: AppTheme.emeraldSuccess,
                      ),
                      activeThumbColor: AppTheme.violetPrimary,
                      value: widget.soundEnabled,
                      onChanged: widget.onToggleSound,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // 4. Data & Reset Section
              _buildSectionHeader('DATA & RESET'),
              const SizedBox(height: 10.0),
              Material(
                color: AppTheme.surfaceCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: AppTheme.borderSubtle),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.cyanAccent,
                      ),
                      title: const Text(
                        'Reset to Sample Habits',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Restores default curated routines',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.0,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                      ),
                      onTap: () {
                        widget.onResetDefaults();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reset to 5 curated daily habits! ✨'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 1.0),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppTheme.roseDanger,
                      ),
                      title: const Text(
                        'Clear All Data',
                        style: TextStyle(
                          color: AppTheme.roseDanger,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Deletes all habits and streaks permanently',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.0,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                      ),
                      onTap: widget.onClearAll,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // 5. App Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Daily Habit Tracker Premium',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Version 2.0.0 • Material 3 Edition\nEngineered with Flutter & Dart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12.0,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.0),
          const SizedBox(height: 6.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
