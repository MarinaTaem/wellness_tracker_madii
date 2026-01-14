import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}

enum TaskStatus { todo, inProgress, completed }

class StudyTask {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final DateTime dueDate;
  final TaskStatus status;
  final int priority; // 1: Low, 2: Medium, 3: High

  StudyTask({
    required this.id,
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
        title: map['title'],
        description: map['description'],
        subjectId: map['subjectId'],
        dueDate: DateTime.parse(map['dueDate']),
        status: TaskStatus.values[map['status']],
        priority: map['priority']);
  }
}

class StudyGoal {
  final String id;
  final String title;
  final double progress; // 0.0 to 1.0
  final DateTime deadline;

  StudyGoal({
    required this.id,
    required this.title,
    required this.progress,
    required this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'progress': progress,
      'deadline': deadline.toIso8601String(),
    };
  }

  factory StudyGoal.fromMap(Map<String, dynamic> map) {
    return StudyGoal(
      id: map['id'],
      title: map['title'],
      progress: map['progress'],
      deadline: DateTime.parse(map['deadline']),
    );
  }
}
