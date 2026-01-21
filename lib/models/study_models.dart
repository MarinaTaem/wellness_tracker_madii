import 'package:flutter/material.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String imgUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.imgUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
    );
  }
}

class Subject {
  final String id;
  final String userId;
  final String name;
  final Color color;
  final IconData icon;

  Subject({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      userId: map['userId'] ?? '',
      name: map['name'],
      color: Color(map['color']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}

enum TaskStatus { todo, inProgress, completed }

class StudyTask {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String subjectId;
  final DateTime dueDate;
  final TaskStatus status;
  final int priority; // 1: Low, 2: Medium, 3: High

  StudyTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.dueDate,
    this.status = TaskStatus.todo,
    this.priority = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'dueDate': dueDate.toIso8601String(),
      'status': status.index,
      'priority': priority,
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    return StudyTask(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'],
      description: map['description'],
      subjectId: map['subjectId'],
      dueDate: DateTime.parse(map['dueDate']),
      status: TaskStatus.values[map['status']],
      priority: map['priority'],
    );
  }
}

class GoalStep {
  final String id;
  final String goalId;
  final String title;
  final bool isCompleted;

  GoalStep({
    required this.id,
    required this.goalId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory GoalStep.fromMap(Map<String, dynamic> map) {
    return GoalStep(
      id: map['id'],
      goalId: map['goalId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

class StudyGoal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime deadline;
  final List<GoalStep> steps;

  StudyGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.deadline,
    this.steps = const [],
  });

  double get progress {
    if (steps.isEmpty) return 0.0;
    final completedCount = steps.where((step) => step.isCompleted).length;
    return completedCount / steps.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
    };
  }

  factory StudyGoal.fromMap(Map<String, dynamic> map,
      {List<GoalStep> steps = const []}) {
    return StudyGoal(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'],
      description: map['description'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      steps: steps,
    );
  }
}

class FocusSession {
  final String id;
  final String userId;
  final String? subjectId;
  final int durationMinutes;
  final DateTime startTime;

  FocusSession({
    required this.id,
    required this.userId,
    this.subjectId,
    required this.durationMinutes,
    required this.startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'subjectId': subjectId,
      'durationMinutes': durationMinutes,
      'startTime': startTime.toIso8601String(),
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'],
      userId: map['userId'],
      subjectId: map['subjectId'],
      durationMinutes: map['durationMinutes'],
      startTime: map['startTime'],
    );
  }
}
