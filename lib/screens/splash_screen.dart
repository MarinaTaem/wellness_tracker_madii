import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/core/app_color.dart';

import '../providers/study_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, _) {
        // Still loading → stay on splash
        if (!studyProvider.isInitialized) {
          return const _SplashView();
        }

        // Finished loading → decide route
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (studyProvider.currentUser == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });

        // Keep showing splash while navigating
        return const _SplashView();
      },
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.school_rounded,
              size: 72,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'StudyActivity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
