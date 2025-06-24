import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/todo_model.dart';
import '../utils/hive_boxes.dart';
import 'notification_service.dart';

class TodoService {
  static Box<TodoModel> get _todoBox {
    try {
      return HiveBoxes.todoBox;
    } catch (e) {
      debugPrint('Error accessing todo box: $e');
      rethrow;
    }
  }

  static List<TodoModel> getAllTodos() {
    try {
      return _todoBox.values.toList();
    } catch (e) {
      debugPrint('Error getting all todos: $e');
      return [];
    }
  }

  static List<TodoModel> getPendingTodos() {
    try {
      return _todoBox.values.where((todo) => !todo.isCompleted).toList();
    } catch (e) {
      debugPrint('Error getting pending todos: $e');
      return [];
    }
  }

  static List<TodoModel> getCompletedTodos() {
    try {
      return _todoBox.values.where((todo) => todo.isCompleted).toList();
    } catch (e) {
      debugPrint('Error getting completed todos: $e');
      return [];
    }
  }

  static List<TodoModel> getOverdueTodos() {
    try {
      return _todoBox.values.where((todo) => todo.isOverdue).toList();
    } catch (e) {
      debugPrint('Error getting overdue todos: $e');
      return [];
    }
  }

  static List<TodoModel> getDueSoonTodos() {
    try {
      return _todoBox.values.where((todo) => todo.isDueSoon).toList();
    } catch (e) {
      debugPrint('Error getting due soon todos: $e');
      return [];
    }
  }

  static Future<void> addTodo(TodoModel todo) async {
    try {
      await _todoBox.put(todo.id, todo);
      await _scheduleNotifications(todo);
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  static Future<void> updateTodo(TodoModel todo) async {
    try {
      await _todoBox.put(todo.id, todo);
      await _cancelNotifications(todo.id);
      if (!todo.isCompleted) {
        await _scheduleNotifications(todo);
      }
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  static Future<void> deleteTodo(String id) async {
    try {
      await _cancelNotifications(id);
      await _todoBox.delete(id);
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  static Future<void> toggleTodoStatus(String id) async {
    try {
      final todo = _todoBox.get(id);
      if (todo != null) {
        todo.isCompleted = !todo.isCompleted;
        await updateTodo(todo);
      }
    } catch (e) {
      debugPrint('Error toggling todo status: $e');
    }
  }

  static List<TodoModel> getSortedTodos({required bool showCompleted}) {
    try {
      List<TodoModel> todos =
          showCompleted ? getCompletedTodos() : getPendingTodos();

      // Sort by overdue first, then due soon, then priority, then creation date
      todos.sort((a, b) {
        // Overdue tasks first
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;

        // Due soon tasks next
        if (a.isDueSoon && !b.isDueSoon) return -1;
        if (!a.isDueSoon && b.isDueSoon) return 1;

        // Then by priority
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority);
        }

        // Finally by creation date
        return b.createdAt.compareTo(a.createdAt);
      });

      return todos;
    } catch (e) {
      debugPrint('Error getting sorted todos: $e');
      return [];
    }
  }

  static Future<void> _scheduleNotifications(TodoModel todo) async {
    try {
      // Schedule reminder notification if set
      if (todo.reminderDateTime != null) {
        await NotificationService.scheduleNotification(
          id: '${todo.id}_reminder'.hashCode,
          title: 'Reminder: ${todo.title}',
          body: todo.description.isNotEmpty
              ? todo.description
              : 'Don\'t forget this task!',
          scheduledDate: todo.reminderDateTime!,
        );
      }

      // Schedule due date notifications
      if (todo.dueDate != null) {
        final dueDate = todo.dueDate!;
        final now = DateTime.now();

        // Schedule notification 24 hours before due date
        final oneDayBefore = dueDate.subtract(const Duration(days: 1));
        if (oneDayBefore.isAfter(now)) {
          await NotificationService.scheduleNotification(
            id: '${todo.id}_due_24h'.hashCode,
            title: 'Due Tomorrow: ${todo.title}',
            body: 'This task is due tomorrow at ${_formatTime(dueDate)}',
            scheduledDate: oneDayBefore,
          );
        }

        // Schedule notification 1 hour before due date
        final oneHourBefore = dueDate.subtract(const Duration(hours: 1));
        if (oneHourBefore.isAfter(now)) {
          await NotificationService.scheduleNotification(
            id: '${todo.id}_due_1h'.hashCode,
            title: 'Due in 1 Hour: ${todo.title}',
            body: 'This task is due at ${_formatTime(dueDate)}',
            scheduledDate: oneHourBefore,
          );
        }

        // Schedule notification at due date
        if (dueDate.isAfter(now)) {
          await NotificationService.scheduleNotification(
            id: '${todo.id}_due_now'.hashCode,
            title: 'Due Now: ${todo.title}',
            body: 'This task is due now!',
            scheduledDate: dueDate,
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  static Future<void> _cancelNotifications(String todoId) async {
    try {
      // Cancel all notification types for this todo
      await NotificationService.cancelNotification(
          '${todoId}_reminder'.hashCode);
      await NotificationService.cancelNotification(
          '${todoId}_due_24h'.hashCode);
      await NotificationService.cancelNotification('${todoId}_due_1h'.hashCode);
      await NotificationService.cancelNotification(
          '${todoId}_due_now'.hashCode);
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
