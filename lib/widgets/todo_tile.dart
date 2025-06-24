import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class TodoTile extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoTile({
    Key? key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: todo.isCompleted ? 1 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: todo.isOverdue && !todo.isCompleted
                ? Border.all(color: Colors.red, width: 2)
                : todo.isDueSoon && !todo.isCompleted
                    ? Border.all(color: Colors.orange, width: 2)
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggle,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: todo.isCompleted
                                ? Colors.green
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          color: todo.isCompleted
                              ? Colors.green
                              : Colors.transparent,
                        ),
                        child: todo.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isCompleted ? Colors.grey[600] : null,
                            ),
                          ),
                          if (todo.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              todo.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: todo.priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        todo.priorityText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: todo.priorityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onTap();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                    ),
                  ],
                ),
                if (todo.dueDate != null || todo.reminderDateTime != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (todo.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: todo.dueDateColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: todo.dueDateColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event,
                                size: 14,
                                color: todo.dueDateColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${todo.dueDate!.day}/${todo.dueDate!.month} ${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: todo.dueDateColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (todo.dueDateStatus.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(${todo.dueDateStatus})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: todo.dueDateColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (todo.reminderDateTime != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 14,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reminder: ${todo.reminderDateTime!.day}/${todo.reminderDateTime!.month} ${todo.reminderDateTime!.hour.toString().padLeft(2, '0')}:${todo.reminderDateTime!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
