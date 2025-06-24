import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import '../widgets/todo_tile.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final settingsBox = Hive.box('settings');
    final currentTheme = settingsBox.get('isDarkMode', defaultValue: false);
    settingsBox.put('isDarkMode', !currentTheme);
  }

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    final userName = settingsBox.get('userName', defaultValue: 'User');
    final isDarkMode = settingsBox.get('isDarkMode', defaultValue: false);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              'Hello, $userName!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTodoList(false), _buildTodoList(true)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddEditScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTodoList(bool showCompleted) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<TodoModel>('todos').listenable(),
      builder: (context, Box<TodoModel> box, widget) {
        final todos = TodoService.getSortedTodos(showCompleted: showCompleted);

        if (todos.isEmpty) {
          return _buildEmptyState(showCompleted);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TodoTile(
                todo: todo,
                onTap: () => _editTodo(todo),
                onToggle: () => TodoService.toggleTodoStatus(todo.id),
                onDelete: () => _deleteTodo(todo),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool showCompleted) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showCompleted ? Icons.celebration : Icons.task_alt,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            showCompleted ? 'No completed tasks yet' : 'No pending tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showCompleted
                ? 'Complete some tasks to see them here'
                : 'Add a new task to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _editTodo(TodoModel todo) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddEditScreen(todo: todo)));
  }

  void _deleteTodo(TodoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              TodoService.deleteTodo(todo.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
