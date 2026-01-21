import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellness_tracker/utils/database_helper.dart';
import '../models/study_models.dart';

class StudyProvider with ChangeNotifier {
  User? _currentUser;
  List<Subject> _subjects = [];
  List<StudyTask> _tasks = [];
  List<StudyGoal> _goals = [];
  List<FocusSession> _focusSessions = [];
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  List<Subject> get subjects => [..._subjects];
  List<StudyTask> get tasks => [..._tasks];
  List<StudyGoal> get goals => [..._goals];
  List<FocusSession> get focusSessions => [..._focusSessions];
  bool get isInitialized => _isInitialized;

  //
  StudyProvider() {
    _init();
  }
  //

  Future<void> _init() async {
    await _checkAutoLogin();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        await _loadUserData();
      }
    }
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    final userId = _currentUser!.id;
    _subjects = await DatabaseHelper.instance.getSubjectsByUser(userId);
    _tasks = await DatabaseHelper.instance.getTasksByUser(userId);
    _goals = await DatabaseHelper.instance.getGoalsByUser(userId);
    _focusSessions =
        await DatabaseHelper.instance.getFocusSessionsByUser(userId);

    if (_subjects.isEmpty && _goals.isEmpty) {
      await _addInitialData();
    }
    notifyListeners();
  }

  Future<void> _addInitialData() async {
    if (_currentUser == null) return;
    final userId = _currentUser!.id;
    final initialSubjects = [
      Subject(
          id: '1_${userId}',
          userId: userId,
          name: 'Mathematics',
          color: Colors.blue,
          icon: Icons.calculate),
      Subject(
          id: '2_${userId}',
          userId: userId,
          name: 'Physics',
          color: Colors.orange,
          icon: Icons.science),
    ];

    for (var subject in initialSubjects) {
      await addSubject(subject);
    }
  }

  // Auth Methods
  Future<bool> signUp(String username, String email, String password) async {
    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        password: password,
      );
      await DatabaseHelper.instance.insertUser(user);
      _currentUser = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);

      await _loadUserData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    final user = await DatabaseHelper.instance.getUser(email, password);
    if (user != null) {
      _currentUser = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);

      await _loadUserData();
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _subjects = [];
    _tasks = [];
    _goals = [];
    _focusSessions = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    notifyListeners();
  }

  // Statistics method
  int get completedTasksCount =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get totalTasksCount => _tasks.length;

  int get totalFocusMinutes {
    return _focusSessions.fold(
        0, (sum, session) => sum + session.durationMinutes);
  }

  Map<String, int> get tasksPerSubject {
    Map<String, int> data = {};
    for (var subject in _subjects) {
      int count = _tasks.where((t) => t.subjectId == subject.id).length;
      if (count > 0) {
        data[subject.name] = count;
      }
    }
    return data;
  }

  Map<String, int> get focusMinutesPerSubject {
    Map<String, int> data = {};
    for (var subject in _subjects) {
      int minutes = _focusSessions
          .where((s) => s.subjectId == subject.id)
          .fold(0, (sum, s) => sum + s.durationMinutes);
      if (minutes > 0) data[subject.name] = minutes;
    }
    return data;
  }

  // Subject CRUD
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

  // Task CRUD
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
        userId: task.userId,
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

  // Goal CRUD
  Future<void> addGoal(StudyGoal goal) async {
    await DatabaseHelper.instance.insertGoal(goal);
    _goals.add(goal);
    notifyListeners();
  }

  Future<void> toggleStepCompletion(String goalId, String stepId) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex >= 0) {
      final goal = _goals[goalIndex];
      final stepIndex = goal.steps.indexWhere((s) => s.id == stepId);
      if (stepIndex >= 0) {
        final step = goal.steps[stepIndex];
        final updatedStep = GoalStep(
          id: step.id,
          goalId: step.goalId,
          title: step.title,
          isCompleted: !step.isCompleted,
        );
        await DatabaseHelper.instance.updateGoalStep(updatedStep);

        final updatedSteps = List<GoalStep>.from(goal.steps);
        updatedSteps[stepIndex] = updatedStep;

        _goals[goalIndex] = StudyGoal(
          id: goal.id,
          userId: goal.userId,
          title: goal.title,
          description: goal.description,
          deadline: goal.deadline,
          steps: updatedSteps,
        );
        notifyListeners();
      }
    }
  }

  Future<void> deleteGoal(String id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // Focus Session CRUD
  Future<void> addFocusSession(int durationMinutes, {String? subjectId}) async {
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.id,
      subjectId: subjectId,
      durationMinutes: durationMinutes,
      startTime: DateTime.now().subtract(Duration(minutes: durationMinutes)),
    );
    await DatabaseHelper.instance.insertFocusSession(session);
    _focusSessions.insert(0, session);
    notifyListeners();
  }
}
