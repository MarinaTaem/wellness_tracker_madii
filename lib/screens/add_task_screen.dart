import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wellness_tracker/core/app_color.dart';

import '../models/study_models.dart';
import '../providers/study_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TaskStatus _selectedStatus = TaskStatus.todo;
  int _selectedPriority = 2;
  Subject? _selectedSubject;

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitTask() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a subject')),
        );
        return;
      }

      final newTask = StudyTask(
        id: const Uuid().v4(),
        userId: provider.currentUser!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subjectId: _selectedSubject!.id,
        dueDate: _selectedDate,
        status: _selectedStatus,
        priority: _selectedPriority,
      );

      Provider.of<StudyProvider>(context, listen: false).addTask(newTask);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Create Task',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
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
                      hintText: 'e.g. Finish math assignment',
                      prefixIcon: Icon(
                        Icons.title,
                        color: AppColor.primaryColor,
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const Divider(),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Optional notes',
                      prefixIcon: Icon(
                        Icons.notes,
                        color: AppColor.primaryColor,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Subject'),
            _card(
              child: Consumer<StudyProvider>(
                builder: (context, studyProvider, _) {
                  final subjects = studyProvider.subjects;

                  if (subjects.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('No subjects available. Add one first.'),
                    );
                  }

                  return DropdownButtonFormField<Subject>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      hintText: 'Choose subject',
                      prefixIcon: Icon(
                        Icons.book,
                        color: AppColor.primaryColor,
                      ),
                      border: InputBorder.none,
                    ),
                    items: subjects.map((subject) {
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
                    onChanged: (value) {
                      setState(() => _selectedSubject = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a subject' : null,
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Schedule'),
            _card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: AppColor.primaryColor,
                ),
                title: const Text('Due Date'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColor.primaryColor,
                ),
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
                      prefixIcon: Icon(
                        Icons.flag,
                        color: AppColor.primaryColor,
                      ),
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
                      prefixIcon: Icon(
                        Icons.priority_high,
                        color: AppColor.primaryColor,
                      ),
                      border: InputBorder.none,
                    ),
                    items: [1, 2, 3, 4, 5].map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          p == 1 ? 'High Priority' : 'Priority $p',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPriority = value!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // space for bottom button
          ],
        ),
      ),
    );
  }
}

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor),
    ),
  );
}

Widget _card({required Widget child}) {
  return Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: child,
    ),
  );
}
