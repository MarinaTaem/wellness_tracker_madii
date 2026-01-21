import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wellness_tracker/core/app_color.dart';
import '../models/study_models.dart';
import '../providers/study_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final StudyTask task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TaskStatus _selectedStatus;
  late int _selectedPriority;
  Subject? _selectedSubject;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    _titleController = TextEditingController(text: task.title);
    _descriptionController = TextEditingController(text: task.description);
    _selectedDate = task.dueDate;
    _selectedStatus = task.status;
    _selectedPriority = task.priority;
    _selectedSubject = studyProvider.subjects.firstWhere(
      (s) => s.id == task.subjectId,
      orElse: () => Subject(
        id: task.subjectId,
        userId: '',
        name: 'Unknown Subject',
        color: Colors.grey,
        icon: Icons.book,
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty || _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and subject are required!')),
      );
      return;
    }

    final updatedTask = StudyTask(
      id: widget.task.id,
      userId: widget.task.userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subjectId: _selectedSubject!.id,
      dueDate: _selectedDate,
      status: _selectedStatus,
      priority: _selectedPriority,
    );

    Provider.of<StudyProvider>(context, listen: false)
        .updateTask(updatedTask)
        .then((_) => Navigator.pop(context));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Update Task',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Task Details'),
          _card(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title, color: AppColor.primaryColor),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes, color: AppColor.primaryColor),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Subject'),
          _card(
            child: DropdownButtonFormField<Subject>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                hintText: 'Choose subject',
                prefixIcon: Icon(Icons.book, color: AppColor.primaryColor),
                border: InputBorder.none,
              ),
              items: studyProvider.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Row(
                    children: [
                      Icon(subject.icon, color: subject.color),
                      const SizedBox(width: 12),
                      Text(subject.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Schedule'),
          _card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today,
                  color: AppColor.primaryColor),
              title: const Text('Due Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
              trailing:
                  const Icon(Icons.chevron_right, color: AppColor.primaryColor),
              onTap: () => _selectDueDate(context),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Task Settings'),
          _card(
            child: Column(
              children: [
                DropdownButtonFormField<TaskStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag, color: AppColor.primaryColor),
                    border: InputBorder.none,
                  ),
                  items: TaskStatus.values.map((status) {
                    String label =
                        status.toString().split('.').last.toUpperCase();
                    if (label == 'INPROGRESS') label = 'IN PROGRESS';
                    return DropdownMenuItem(
                      value: status,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedStatus = value!),
                ),
                const Divider(),
                DropdownButtonFormField<int>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon:
                        Icon(Icons.priority_high, color: AppColor.primaryColor),
                    border: InputBorder.none,
                  ),
                  items: [1, 2, 3, 4, 5].map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p == 1 ? 'High Priority' : 'Priority $p'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedPriority = value!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// Helper widgets
Widget _sectionTitle(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor,
        ),
      ),
    );

Widget _card({required Widget child}) => Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
