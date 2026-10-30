import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/main.dart';
import 'package:habit_tracker/widgets/habit_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Daily Habit Tracker Premium UI and Multi-Tab Navigation',
      (WidgetTester tester) async {
    // 1. Launch the application
    await tester.pumpWidget(const DailyHabitTrackerApp());
    await tester.pumpAndSettle();

    // Verify Home Dashboard elements
    expect(find.text('YOUR DAILY PROGRESS'), findsOneWidget);
    expect(find.text("Today's Habits"), findsOneWidget);

    // Verify default curated habits are present
    expect(find.byType(HabitCard), findsWidgets);

    // 2. Test Tab Navigation to Analytics (tap icon)
    await tester.tap(find.byIcon(Icons.insights_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Performance Analytics'), findsOneWidget);
    expect(find.text('Weekly Activity'), findsOneWidget);

    // 3. Test Tab Navigation to Calendar (tap icon)
    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Habit History'), findsOneWidget);

    // 4. Test Tab Navigation to Profile (tap icon)
    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Habit Builder'), findsOneWidget);
    expect(find.text('PREFERENCES & SETTINGS'), findsOneWidget);

    // 5. Navigate back to Today / Home
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
    expect(find.text("Today's Habits"), findsOneWidget);

    // 6. Test FAB opens Add Habit Bottom Sheet
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('Create New Habit'), findsOneWidget);
    expect(find.text('HABIT NAME'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);

    // 7. Test Validation on empty submit
    final createButton = find.widgetWithText(ElevatedButton, 'Create Habit');
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a habit name.'), findsOneWidget);

    // 8. Enter habit name and save
    final textField = find.byType(TextField).first;
    await tester.enterText(textField, 'Stretching Routine');
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Scroll down to locate the newly appended habit in the list
    final habitFinder = find.text('Stretching Routine');
    await tester.scrollUntilVisible(
      habitFinder,
      150.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(habitFinder, findsOneWidget);
  });
}
