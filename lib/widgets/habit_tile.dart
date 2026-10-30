import 'package:flutter/material.dart';
import '../models/habit.dart';

/// A reusable card widget that displays an individual [Habit].
///
/// Features:
/// - Rounded card with subtle border and shadow.
/// - Interactive checkbox to toggle habit completion.
/// - Visual differentiation between completed and incomplete habits
///   (strike-through text, tinted background, color change).
/// - Delete button that triggers a confirmation dialog.
class HabitTile extends StatelessWidget {
  /// The habit model to display.
  final Habit habit;

  /// Callback when the completion checkbox or card is toggled.
  final VoidCallback onToggle;

  /// Callback when the delete icon is pressed.
  final VoidCallback onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = habit.isCompleted;

    // Visual design tokens based on completion state
    final Color backgroundColor = isCompleted
        ? const Color(0xFFF0FDF4) // Light soft mint/green tint
        : Colors.white;

    final Color borderColor = isCompleted
        ? const Color(0xFF86EFAC) // Mint green border
        : const Color(0xFFE2E8F0); // Subtle slate gray border

    final Color textColor = isCompleted
        ? const Color(0xFF64748B) // Muted slate gray
        : const Color(0xFF0F172A); // High contrast dark slate

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                // Custom-styled Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: (_) => onToggle(),
                    activeColor: const Color(0xFF10B981), // Emerald green
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    side: BorderSide(
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      width: 1.8,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Habit Name / Title with completion styling
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        habit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16.0,
                          fontWeight: isCompleted
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: textColor,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: const Color(0xFF64748B),
                          decorationThickness: 2.0,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(height: 2.0),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 13.0,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Done for today',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF059669),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), // Soft red
                  ),
                  tooltip: 'Delete habit',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
