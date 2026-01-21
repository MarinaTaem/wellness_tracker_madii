import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/providers/study_provider.dart';
import '../models/study_models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = 'Weekly';

  DateTime getStartDate(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Daily':
        return now.subtract(const Duration(days: 1));
      case 'Weekly':
        return now.subtract(const Duration(days: 7));
      case 'Monthly':
        return now.subtract(const Duration(days: 30));
      case 'Yearly':
        return now.subtract(const Duration(days: 365));
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final startDate = getStartDate(selectedPeriod);
    final filteredTasks =
        studyProvider.tasks.where((t) => t.dueDate.isAfter(startDate)).toList();
    final filteredFocusSessions = studyProvider.focusSessions
        .where((s) => s.startTime.isAfter(startDate))
        .toList();

    final tasksPerSubject = <String, int>{};
    for (var subject in studyProvider.subjects) {
      int count = filteredTasks.where((t) => t.subjectId == subject.id).length;
      if (count > 0) {
        tasksPerSubject[subject.name] = count;
      }
    }

    final focusPerSubject = <String, int>{};
    for (var subject in studyProvider.subjects) {
      int minutes = filteredFocusSessions
          .where((s) => s.subjectId == subject.id)
          .fold(0, (sum, s) => sum + s.durationMinutes);
      if (minutes > 0) {
        focusPerSubject[subject.name] = minutes;
      }
    }

    final totalTasks = filteredTasks.length;
    final completedTasks =
        filteredTasks.where((t) => t.status == TaskStatus.completed).length;
    final totalFocusMinutes = filteredFocusSessions.fold(
        0, (sum, session) => sum + session.durationMinutes);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildStatCards(completedTasks, totalTasks, totalFocusMinutes),
            const SizedBox(height: 32),
            const Text(
              'Task Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            tasksPerSubject.isEmpty
                ? const Center(child: Text('No task data available'))
                : SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: tasksPerSubject.entries.map((entry) {
                          final index =
                              tasksPerSubject.keys.toList().indexOf(entry.key);
                          final colors = [
                            const Color(0xFF6C63FF),
                            const Color(0xFF03DAC6),
                            Colors.orange,
                            Colors.pink,
                            Colors.amber,
                            Colors.green,
                            Colors.purple,
                            Colors.amberAccent
                          ];
                          return PieChartSectionData(
                            value: entry.value.toDouble(),
                            color: colors[index % colors.length],
                            title: entry.key,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((period) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: period == selectedPeriod,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedPeriod = period);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCards(int completed, int total, int focus) {
    return Column(
      children: [
        Row(
          children: [
            _statCard(
              'Focus Time',
              '${focus}m',
              Icons.timer,
              Colors.orange,
            ),
            const SizedBox(width: 16),
            _statCard(
              'Completed',
              completed.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _statCard(
              'Total Tasks',
              total.toString(),
              Icons.assignment,
              Colors.blue,
            ),
            const SizedBox(width: 16),
            _statCard(
              'Efficiency',
              total == 0 ? '0%' : '${(completed / total * 100).toInt()}%',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
