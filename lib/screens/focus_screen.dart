import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/core/app_color.dart';
import 'package:wellness_tracker/providers/study_provider.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int _selectedMinutes = 25;
  int _secondsRemaining = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  // String? _selectedSubjectId;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _completeSession();
          }
        });
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _completeSession() {
    Provider.of<StudyProvider>(context, listen: false)
        .addFocusSession(_selectedMinutes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Focus session of $_selectedMinutes minutes recorded!'),
      ),
    );
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _selectedMinutes * 60;
      _isRunning = false;
    });
  }

  void _updateDuration(int minutes) {
    if (!_isRunning) {
      setState(() {
        _selectedMinutes = minutes;
        _secondsRemaining = minutes * 60;
      });
    }
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percent = _secondsRemaining / (_selectedMinutes * 60);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Time')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Set Study Duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [15, 25, 45, 60].map((mins) {
                bool isSelected = _selectedMinutes == mins;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$mins min'),
                    selected: isSelected,
                    onSelected: _isRunning
                        ? null
                        : (selected) {
                            if (selected) _updateDuration(mins);
                          },
                    selectedColor: AppColor.primaryColor,
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 52),
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 12.0,
              percent: percent,
              center: Text(
                _formatTime(_secondsRemaining),
                style:
                    const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              progressColor: AppColor.primaryColor,
              backgroundColor: Colors.grey.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
