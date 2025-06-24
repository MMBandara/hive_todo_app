import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';

class AddEditScreen extends StatefulWidget {
  final TodoModel? todo;

  const AddEditScreen({Key? key, this.todo}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _priority = 0;
  DateTime? _reminderDateTime;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _priority = widget.todo!.priority;
      _reminderDateTime = widget.todo!.reminderDateTime;
      _dueDate = widget.todo!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTodo() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final todo = TodoModel(
      id: widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: widget.todo?.isCompleted ?? false,
      createdAt: widget.todo?.createdAt ?? DateTime.now(),
      reminderDateTime: _reminderDateTime,
      priority: _priority,
      dueDate: _dueDate,
    );

    if (widget.todo == null) {
      await TodoService.addTodo(todo);
    } else {
      await TodoService.updateTodo(todo);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _selectReminderDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_reminderDateTime ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _reminderDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Task' : 'Edit Task'),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriorityChip('Low', 0, Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriorityChip('Medium', 1, Colors.orange),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriorityChip('High', 2, Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDueDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dueDate == null
                                    ? 'Set due date'
                                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} at ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: _dueDate == null
                                      ? Colors.grey[600]
                                      : null,
                                ),
                              ),
                            ),
                            if (_dueDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _dueDate = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectReminderDateTime,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _reminderDateTime == null
                                    ? 'Set reminder'
                                    : '${_reminderDateTime!.day}/${_reminderDateTime!.month}/${_reminderDateTime!.year} at ${_reminderDateTime!.hour.toString().padLeft(2, '0')}:${_reminderDateTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: _reminderDateTime == null
                                      ? Colors.grey[600]
                                      : null,
                                ),
                              ),
                            ),
                            if (_reminderDateTime != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _reminderDateTime = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, int value, Color color) {
    final isSelected = _priority == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _priority = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
