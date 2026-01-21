import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wellness_tracker/core/app_color.dart';
import '../models/study_models.dart';
import '../providers/study_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  final List<TextEditingController> _stepControllers = [
    TextEditingController()
  ];

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveGoal() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (_formKey.currentState!.validate() && provider.currentUser != null) {
      final goalId = DateTime.now().millisecondsSinceEpoch.toString();
      final userId = provider.currentUser!.id;
      final steps = _stepControllers
          .where((c) => c.text.isNotEmpty)
          .map((c) => GoalStep(
                id: DateTime.now().millisecondsSinceEpoch.toString() +
                    c.text.hashCode.toString(),
                goalId: goalId,
                title: c.text,
              ))
          .toList();

      final newGoal = StudyGoal(
        id: goalId,
        userId: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        deadline: _selectedDate,
        steps: steps,
      );
      provider.addGoal(newGoal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme.copyWith(
          floatingLabelStyle: const TextStyle(color: AppColor.primaryColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColor.primaryColor, width: 1.5),
          ),
        );

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: inputTheme,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Goal'),
          centerTitle: true,
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveGoal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Create Goal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Goal Details'),
              _card(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Goal Title',
                        hintText: 'e.g. Improve Flutter skills',
                        prefixIcon:
                            Icon(Icons.flag, color: AppColor.primaryColor),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Why is this goal important?',
                        prefixIcon:
                            Icon(Icons.notes, color: AppColor.primaryColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Deadline'),
              _card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today,
                      color: AppColor.primaryColor),
                  title: const Text('Target Date'),
                  subtitle:
                      Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Steps'),
              _card(
                child: Column(
                  children: _stepControllers.asMap().entries.map((entry) {
                    final idx = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                labelText: 'Step ${idx + 1}',
                                hintText: 'Describe this step',
                                prefixIcon: const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColor.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeStep(idx),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add, color: AppColor.primaryColor),
                label: const Text(
                  'Add another step',
                  style: TextStyle(color: AppColor.primaryColor),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
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
        color: AppColor.primaryColor,
      ),
    ),
  );
}

Widget _card({required Widget child}) {
  return Card(
    elevation: 1,
    shadowColor: AppColor.primaryColor.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: child,
    ),
  );
}
