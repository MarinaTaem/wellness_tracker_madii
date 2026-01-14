import 'package:flutter/material.dart';
import 'package:wellness_tracker/utils/database_helper.dart';
import '../models/study_models.dart';

class StudyProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  List<StudyTask> _tasks = [];
  List<StudyGoal> _goals = [];

  List<Subject> get subjects => [..._subjects];
  List<StudyTask> get tasks => [..._tasks];
  List<StudyGoal> get goals => [..._goals];

  //
  StudyProvider() {
    _loadData();
  }
  //

  Future<void> _loadData() async {
    _subjects = await DatabaseHelper.instance.getAllSubjects();
    _tasks = await DatabaseHelper.instance.getAllTasks();
    _goals = await DatabaseHelper.instance.getAllGoal();

    // Tast data - initial data if empty
    if (_subjects.isEmpty) {
      _addInitialData();
    }
  }

  Future<void> _addInitialData() async {
    final initialSubjects = [
      Subject(
          id: '1',
          name: 'Mathematics',
          color: Colors.blue,
          icon: Icons.calculate),
      Subject(
          id: '2', name: 'Physics', color: Colors.orange, icon: Icons.science),
      Subject(
          id: '3',
          name: 'History',
          color: Colors.brown,
          icon: Icons.history_edu),
    ];

    for (var subject in initialSubjects) {
      await addSubject(subject);
    }

    final initialTasks = [
      StudyTask(
        id: '1',
        title: 'Calculus Homework',
        description: 'Complete exercises 1-10',
        subjectId: '1',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: 3,
      ),
    ];

    for (var task in initialTasks) {
      await addTask(task);
    }

    final initialGoal = StudyGoal(
      id: '1',
      title: 'Finish Semester Project',
      progress: 0.65,
      deadline: DateTime.now().add(const Duration(days: 30)),
    );
    await addGoal(initialGoal);
  }

  Future<void> addSubject(Subject subject) async {
    await DatabaseHelper.instance.insertSubject(subject);
    _subjects.add(subject);
    notifyListeners();
  }

  // Future<void> updateSubject(Subject subject) async {
  //   final index = _subjects.indexWhere((s) => s.id == subject.id);
  //   if (index >= 0) {
  //     _subjects[index] = subject;
  //     notifyListeners();
  //   }
  // }

  Future<void> deleteSubject(String id) async {
    await DatabaseHelper.instance.deleteSubject(id);
    _subjects.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> addTask(StudyTask task) async {
    await DatabaseHelper.instance.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final task = _tasks[index];
      final updatedTask = StudyTask(
        id: task.id,
        title: task.title,
        description: task.description,
        subjectId: task.subjectId,
        dueDate: task.dueDate,
        status: status,
        priority: task.priority,
      );
      await DatabaseHelper.instance.updateTask(updatedTask);
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Future<void> addGoal(StudyGoal goal) async {
    await DatabaseHelper.instance.insertGoal(goal);
    _goals.add(goal);
    notifyListeners();
  }
}
