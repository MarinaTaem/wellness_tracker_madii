import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/providers/study_provider.dart';
import 'package:wellness_tracker/providers/theme_provider.dart';
import 'package:wellness_tracker/screens/home_screen.dart';
import 'package:wellness_tracker/screens/login_screen.dart';
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
    final studyProvider = Provider.of<StudyProvider>(context);

    return MaterialApp(
      title: 'StudyActivity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // home: HomeScreen(),
      home: !studyProvider.isInitialized == null
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : (studyProvider.currentUser == null
              ? const LoginScreen()
              : const HomeScreen()),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
