import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/providers/study_provider.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final goal = studyProvider.goals.firstWhere((g) => g.id == goalId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(context, studyProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 8.0,
                      percent: goal.progress,
                      center: Text(
                        '${(goal.progress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      progressColor: const Color(0xFF6C63FF),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deadline: ${DateFormat('MMM d, yyyy').format(goal.deadline)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              goal.description.isEmpty
                  ? 'No description provided.'
                  : goal.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Action Steps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${goal.steps.where((s) => s.isCompleted).length}/${goal.steps.length}',
                  style: const TextStyle(
                      color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...goal.steps.map((step) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CheckboxListTile(
                    title: Text(
                      step.title,
                      style: TextStyle(
                        decoration: step.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: step.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    value: step.isCompleted,
                    onChanged: (_) {
                      studyProvider.toggleStepCompletion(goal.id, step.id);
                    },
                    activeColor: const Color(0xFF6C63FF),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StudyProvider provider) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Delete Goal'),
              content: const Text(
                  'Are you sure you want to delete this goal and all its steps?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Concel'),
                ),
                TextButton(
                  onPressed: () {
                    provider.deleteGoal(goalId);
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // back o goal list
                  },
                  child: Text('Delted', style: TextStyle(color: Colors.red)),
                )
              ],
            ));
  }
}
