import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wellness_tracker/screens/add_task_screen.dart';
import 'package:wellness_tracker/screens/task_detail_screen.dart';
import 'package:wellness_tracker/widgets/task_card.dart';
import '../providers/study_provider.dart';
import '../models/study_models.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);

    // Group tasks by subjectId
    final Map<String, List<StudyTask>> tasksBySubject = {};
    for (var task in studyProvider.tasks) {
      if (task.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        tasksBySubject.putIfAbsent(task.subjectId, () => []).add(task);
      }
    }

    // Sort subjects by name (optional)
    final sortedSubjectIds = tasksBySubject.keys.toList()
      ..sort((a, b) {
        final nameA = studyProvider.subjects
            .firstWhere((s) => s.id == a,
                orElse: () => Subject(
                    id: a,
                    userId: '',
                    name: 'Unknown',
                    color: Colors.grey,
                    icon: Icons.book))
            .name;
        final nameB = studyProvider.subjects
            .firstWhere((s) => s.id == b,
                orElse: () => Subject(
                    id: b,
                    name: 'Unknown',
                    userId: '',
                    color: Colors.grey,
                    icon: Icons.book))
            .name;
        return nameA.compareTo(nameB);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          // Grouped tasks list
          Expanded(
            child: sortedSubjectIds.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: sortedSubjectIds.length,
                    itemBuilder: (context, index) {
                      final subjectId = sortedSubjectIds[index];
                      final tasks = tasksBySubject[subjectId]!;

                      final subject = studyProvider.subjects.firstWhere(
                        (s) => s.id == subjectId,
                        orElse: () => Subject(
                          id: subjectId,
                          userId: '',
                          name: 'Unknown Subject',
                          color: Colors.grey,
                          icon: Icons.book,
                        ),
                      );

                      final completedCount = tasks
                          .where((t) => t.status == TaskStatus.completed)
                          .length;
                      final totalCount = tasks.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subject Header Card
                          Container(
                            margin: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: subject.color.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  subject.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$completedCount/$totalCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tasks under this subject
                          ...tasks.map((task) {
                            final subject = studyProvider.subjects.firstWhere(
                              (s) => s.id == task.subjectId,
                              orElse: () => Subject(
                                id: task.subjectId,
                                userId: '',
                                name: 'Unknown Subject',
                                color: Colors.grey,
                                icon: Icons.book,
                              ),
                            );
                            return TaskCard(
                              task: task,
                              subjectColor: subject.color,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TaskDetailScreen(task: task),
                                  ),
                                );
                              },
                              onToggleStatus: () {
                                final newStatus =
                                    task.status == TaskStatus.completed
                                        ? TaskStatus.todo
                                        : TaskStatus.completed;
                                studyProvider.updateTaskStatus(
                                    task.id, newStatus);
                              },
                            );

                            // Card(

                            //   margin: const EdgeInsets.symmetric(
                            //     horizontal: 4,
                            //     vertical: 5,
                            //   ),
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   elevation: 1,
                            //   child: ListTile(
                            //     contentPadding: const EdgeInsets.symmetric(
                            //       horizontal: 16,
                            //       vertical: 4,
                            //     ),
                            // leading: Container(
                            //   width: 5,
                            //   decoration: BoxDecoration(
                            //     color: subject.color,
                            //     borderRadius: BorderRadius.circular(3),
                            //   ),
                            //     ),
                            //     title: Text(
                            //       task.title,
                            //       style: TextStyle(
                            //         decoration:
                            //             task.status == TaskStatus.completed
                            //                 ? TextDecoration.lineThrough
                            //                 : null,
                            //         color: task.status == TaskStatus.completed
                            //             ? Colors.grey.shade700
                            //             : null,
                            //       ),
                            //     ),
                            //     subtitle: Text(
                            //       'Due ${DateFormat('MMM d').format(task.dueDate)} ${task.priority > 3 ? ' • High Priority' : ''}',
                            //       style: TextStyle(
                            //         color: Colors.grey.shade600,
                            //       ),
                            //     ),
                            //     trailing: Checkbox(
                            //       value: task.status == TaskStatus.completed,
                            //       activeColor: subject.color,
                            //       onChanged: (value) {
                            //         studyProvider.updateTaskStatus(
                            //           task.id,
                            //           value!
                            //               ? TaskStatus.completed
                            //               : TaskStatus.todo,
                            //         );
                            //       },
                            //     ),
                            //     onTap: () {
                            //       // Optional: open task detail/edit screen
                            //     },
                            //   ),
                            // );
                          }).toList(),

                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add_task),
        label: const Text('Add Task'),
      ),
    );
  }
}
