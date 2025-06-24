import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? reminderDateTime;

  @HiveField(6)
  int priority; // 0: Low, 1: Medium, 2: High

  @HiveField(7)
  DateTime? dueDate;

  TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.reminderDateTime,
    this.priority = 0,
    this.dueDate,
  });

  String get priorityText {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Low';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final timeDiff = dueDate!.difference(now);
    return timeDiff.inHours <= 24 && timeDiff.inHours > 0;
  }

  String get dueDateStatus {
    if (dueDate == null) return '';
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (isDueSoon) return 'Due Soon';
    return 'Upcoming';
  }

  Color get dueDateColor {
    if (dueDate == null || isCompleted) return Colors.grey;
    if (isOverdue) return Colors.red;
    if (isDueSoon) return Colors.orange;
    return Colors.blue;
  }
}
