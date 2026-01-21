import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellness_tracker/models/study_models.dart';

class TaskCard extends StatelessWidget {
  final StudyTask task;
  final Color subjectColor; // <-- color from the subject
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;

  const TaskCard({
    super.key,
    required this.task,
    required this.subjectColor,
    required this.onTap,
    required this.onToggleStatus,
  });

  Color getPriorityColor(int priority) {
    if (priority == 1) return Colors.red;
    if (priority == 2) return Colors.orange;
    if (priority == 3) return Colors.amber;
    return Colors.grey;
  }

  List<Widget> buildStars(int priority) {
    return List.generate(
      5,
      (index) => Icon(
        Icons.star,
        size: 16,
        color: index < priority ? getPriorityColor(priority) : Colors.grey[300],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            /// Subject color bar
            Container(
              width: 5,
              height: 80, // match card height roughly
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    /// Task info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.status == TaskStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (task.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  decoration:
                                      task.status == TaskStatus.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(children: buildStars(task.priority)),
                        ],
                      ),
                    ),

                    /// Checkbox at the right
                    IconButton(
                      icon: Icon(
                        task.status == TaskStatus.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: Colors.green,
                        size: 28,
                      ),
                      onPressed: onToggleStatus,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
