import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wellness_tracker/screens/tasks_screen.dart';

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
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a subject')),
        );
        return;
      }

      final newTask = StudyTask(
        id: const Uuid().v4(),
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
        title: Text('Add task'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Subject Dropdown - pulls from Provider
              Consumer<StudyProvider>(
                builder: (context, studyProvider, child) {
                  final subjects = studyProvider.subjects;

                  if (subjects.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No subjects available. Add one first!'),
                      ),
                    );
                  }

                  return DropdownButtonFormField<Subject>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    hint: const Text('Choose a subject'),
                    items: subjects.map((Subject subject) {
                      return DropdownMenuItem<Subject>(
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
                    onChanged: (Subject? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a subject';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Due Date
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Due Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () => _selectDueDate(context),
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<TaskStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: TaskStatus.values.map((status) {
                  String label = status.toString().split('.').last;
                  label = label[0].toUpperCase() + label.substring(1);
                  if (label == 'Inprogress') label = 'In Progress';
                  return DropdownMenuItem(
                    value: status,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Priority
              DropdownButtonFormField<int>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority (1 = Highest)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: [1, 2, 3, 4, 5].map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text('Priority $p${p == 1 ? ' (Highest)' : ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Task',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
