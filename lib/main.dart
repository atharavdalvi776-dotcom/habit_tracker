import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

/// Entry point of the Daily Habit Tracker application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set dark navigation and transparent status bar for edge-to-edge immersion
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgMidnight,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const DailyHabitTrackerApp());
}

/// Root widget of the application.
class DailyHabitTrackerApp extends StatelessWidget {
  const DailyHabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
