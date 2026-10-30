import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

/// A premium, interactive card widget representing an individual [Habit].
///
/// Features:
/// - Distinct category badge with vibrant color accent.
/// - Custom icon container with glowing ambient background.
/// - Animated circular check button with bounce/scale micro-interaction.
/// - Streak counter chip ("🔥 X days").
/// - Seamless visual differentiation for completed states (strike-through, tinted border).
/// - Edit and Delete actions via tap and popup menu.
class HabitCard extends StatefulWidget {
  final Habit habit;
  final String dateKey;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.dateKey,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _animController.forward();
    await _animController.reverse();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final isCompleted = habit.isCompletedOn(widget.dateKey);
    final streak = habit.calculateCurrentStreak();
    final habitColor = habit.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.surfaceCard.withValues(alpha: 0.7)
            : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: isCompleted
              ? habitColor.withValues(alpha: 0.45)
              : AppTheme.borderSubtle,
          width: isCompleted ? 1.4 : 1.0,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: habitColor.withValues(alpha: 0.12),
                  blurRadius: 16.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22.0),
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                // 1. Habit Icon Container with subtle glow
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: isCompleted ? 0.15 : 0.22),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: habitColor.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    habit.iconData,
                    color: isCompleted
                        ? habitColor.withValues(alpha: 0.7)
                        : habitColor,
                    size: 24.0,
                  ),
                ),

                const SizedBox(width: 14.0),

                // 2. Habit Title, Description & Category Chip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category Tag & Streak Chip
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: habitColor.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              habit.category.toUpperCase(),
                              style: TextStyle(
                                color: habitColor,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (streak > 0) ...[
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 10.0),
                                  ),
                                  const SizedBox(width: 3.0),
                                  Text(
                                    '$streak d',
                                    style: const TextStyle(
                                      color: Color(0xFFFB923C),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6.0),

                      // Title
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppTheme.textMuted,
                          decorationThickness: 2.0,
                        ),
                      ),

                      // Subtitle / Description
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 3.0),
                        Text(
                          habit.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isCompleted
                                ? AppTheme.textMuted.withValues(alpha: 0.7)
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10.0),

                // 3. Actions: Menu & Animated Check Button
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppTheme.textMuted,
                    size: 20.0,
                  ),
                  color: AppTheme.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: const BorderSide(
                      color: AppTheme.borderSubtle,
                      width: 1.0,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.onEdit();
                    } else if (value == 'delete') {
                      widget.onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 18.0,
                            color: AppTheme.cyanAccent,
                          ),
                          SizedBox(width: 10.0),
                          Text('Edit Habit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18.0,
                            color: AppTheme.roseDanger,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppTheme.roseDanger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 4. Animated Check Button with micro-bounce
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: _handleTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 38.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCompleted
                            ? LinearGradient(
                                colors: [
                                  habitColor,
                                  habitColor.withValues(alpha: 0.75),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isCompleted
                            ? null
                            : Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: isCompleted
                              ? habitColor
                              : AppTheme.textMuted.withValues(alpha: 0.4),
                          width: 2.0,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: habitColor.withValues(alpha: 0.4),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 22.0,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

