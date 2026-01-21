import 'package:flutter/material.dart';
import 'package:wellness_tracker/utils/database_helper.dart';
import '../models/study_models.dart';

class StudyProvider with ChangeNotifier {
  User? _currentUser;
  List<Subject> _subjects = [];
  List<StudyTask> _tasks = [];
  List<StudyGoal> _goals = [];
  List<FocusSession> _focusSessions = [];

  User? get currentUser => _currentUser;
  List<Subject> get subjects => [..._subjects];
  List<StudyTask> get tasks => [..._tasks];
  List<StudyGoal> get goals => [..._goals];
  List<FocusSession> get focusSessions => [..._focusSessions];

  //
  StudyProvider() {
    _loadData();
  }
  //

  Future<void> _loadData() async {
    _subjects = await DatabaseHelper.instance.getAllSubjects();
    _tasks = await DatabaseHelper.instance.getAllTasks();
    _goals = await DatabaseHelper.instance.getAllGoal();
    _focusSessions = await DatabaseHelper.instance.getAllFocusSessions();

    // Tast data - initial data if empty
    if (_subjects.isEmpty && _goals.isEmpty) {
      await _addInitialData();
    }

    notifyListeners();
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

    final goalId = DateTime.now().millisecondsSinceEpoch.toString();
    final initialGoal = StudyGoal(
      id: '1',
      title: 'Finish Semester Project',
      description: 'Learn Flutter from basic to advaced state management.',
      deadline: DateTime.now().add(const Duration(days: 30)),
      steps: [
        GoalStep(
            id: 's1',
            goalId: goalId,
            title: 'Learn Dart Basics',
            isCompleted: true),
        GoalStep(
            id: 's2',
            goalId: goalId,
            title: 'Understand Widgets',
            isCompleted: false),
        GoalStep(
            id: 's3',
            goalId: goalId,
            title: 'Master Provider',
            isCompleted: false),
      ],
    );
    await addGoal(initialGoal);
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
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    final user = await DatabaseHelper.instance.getUser(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void signOut() {
    _currentUser = null;
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

  // double get taskCompletionRate =>
  //     totalTasksCount == 0 ? 0 : completedTasksCount / totalTasksCount;

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
        final updateStep = GoalStep(
          id: step.id,
          goalId: step.goalId,
          title: step.title,
          isCompleted: !step.isCompleted,
        );
        await DatabaseHelper.instance.updateGoalStep(updateStep);

        // Update local state
        final updateSteps = List<GoalStep>.from(goal.steps);
        updateSteps[stepIndex] = updateStep;

        _goals[goalIndex] = StudyGoal(
          id: goal.id,
          title: goal.title,
          description: goal.description,
          deadline: goal.deadline,
          steps: updateSteps,
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
      subjectId: subjectId,
      durationMinutes: durationMinutes,
      startTime: DateTime.now().subtract(Duration(minutes: durationMinutes)),
    );
    await DatabaseHelper.instance.insertFocusSession(session);
    _focusSessions.insert(0, session);
    notifyListeners();
  }
}
