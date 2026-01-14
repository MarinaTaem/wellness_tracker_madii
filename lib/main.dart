import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/providers/study_provider.dart';
import 'package:wellness_tracker/providers/theme_provider.dart';
import 'package:wellness_tracker/screens/add_task_screen.dart';
import 'package:wellness_tracker/screens/home_screen.dart';
import 'package:wellness_tracker/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'StudyActivity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
