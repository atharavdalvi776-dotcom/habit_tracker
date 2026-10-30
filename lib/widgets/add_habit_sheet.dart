import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

/// Bottom sheet modal for creating or editing a [Habit].
///
/// Features:
/// - Text validation for habit name.
/// - Optional description field.
/// - Category selector chips with associated icons and colors.
/// - Icon picker grid.
/// - Gradient submit button with interaction feedback.
class AddHabitSheet extends StatefulWidget {
  /// If provided, the sheet operates in Edit Mode.
  final Habit? existingHabit;

  /// Callback when habit is submitted (new or updated).
  final ValueChanged<Habit> onSave;

  const AddHabitSheet({
    super.key,
    this.existingHabit,
    required this.onSave,
  });

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late HabitCategoryOption _selectedCategory;
  late int _selectedIconCode;
  String? _errorMessage;

  static const List<IconData> _availableIcons = [
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.self_improvement_rounded,
    Icons.lightbulb_rounded,
    Icons.code_rounded,
    Icons.directions_run_rounded,
    Icons.bedtime_rounded,
    Icons.restaurant_rounded,
    Icons.brush_rounded,
    Icons.laptop_chromebook_rounded,
    Icons.favorite_rounded,
    Icons.music_note_rounded,
    Icons.pets_rounded,
    Icons.nature_people_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingHabit;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descController = TextEditingController(text: existing?.description ?? '');

    if (existing != null) {
      _selectedCategory = HabitCategoryOption.all.firstWhere(
        (c) => c.name.toLowerCase() == existing.category.toLowerCase(),
        orElse: () => HabitCategoryOption.all.first,
      );
      _selectedIconCode = existing.iconCodePoint;
    } else {
      _selectedCategory = HabitCategoryOption.all.first;
      _selectedIconCode = _selectedCategory.icon.codePoint;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a habit name.';
      });
      return;
    }

    final Habit habitToSave;
    if (widget.existingHabit != null) {
      habitToSave = widget.existingHabit!.copyWith(
        title: title,
        description: _descController.text.trim(),
        category: _selectedCategory.name,
        iconCodePoint: _selectedIconCode,
        colorValue: _selectedCategory.color.toARGB32(),
      );
    } else {
      habitToSave = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: _descController.text.trim(),
        category: _selectedCategory.name,
        iconCodePoint: _selectedIconCode,
        colorValue: _selectedCategory.color.toARGB32(),
        completedDates: [],
        createdAt: DateTime.now(),
      );
    }

    widget.onSave(habitToSave);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingHabit != null;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 14.0,
        bottom: viewInsets + 24.0,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Habit' : 'Create New Habit',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14.0),

            // Habit Name Input
            const Text(
              'HABIT NAME',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6.0),
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16.0),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'e.g. Read 20 Pages, Drink Water',
                hintStyle: TextStyle(
                  color: AppTheme.textMuted.withValues(alpha: 0.7),
                ),
                errorText: _errorMessage,
                filled: true,
                fillColor: AppTheme.bgMidnight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(
                    color: AppTheme.violetPrimary,
                    width: 1.6,
                  ),
                ),
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 14.0),

            // Description / Subtitle Input
            const Text(
              'DESCRIPTION (OPTIONAL)',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6.0),
            TextField(
              controller: _descController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14.0),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'e.g. 30 minutes before sleep',
                hintStyle: TextStyle(
                  color: AppTheme.textMuted.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: AppTheme.bgMidnight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(
                    color: AppTheme.violetPrimary,
                    width: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // Category Selection
            const Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: HabitCategoryOption.all.map((category) {
                  final isSelected =
                      _selectedCategory.name == category.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 14.0,
                            color: isSelected
                                ? Colors.white
                                : category.color,
                          ),
                          const SizedBox(width: 6.0),
                          Text(category.name),
                        ],
                      ),
                      selectedColor: category.color,
                      backgroundColor: AppTheme.bgMidnight,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: isSelected
                              ? category.color
                              : AppTheme.borderSubtle,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                            _selectedIconCode = category.icon.codePoint;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18.0),

            // Icon Selection Grid
            const Text(
              'SELECT ICON',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIconCode == icon.codePoint;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconCode = icon.codePoint;
                    });
                  },
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedCategory.color.withValues(alpha: 0.25)
                          : AppTheme.bgMidnight,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: isSelected
                            ? _selectedCategory.color
                            : AppTheme.borderSubtle,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 22.0,
                      color: isSelected
                          ? _selectedCategory.color
                          : AppTheme.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24.0),

            // Save / Create Button
            Container(
              width: double.infinity,
              height: 52.0,
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: AppTheme.violetGlow,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                onPressed: _handleSubmit,
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Habit',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

