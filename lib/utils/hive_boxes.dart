import 'package:hive/hive.dart';
import '../models/todo_model.dart';

class HiveBoxes {
  static Box<TodoModel> get todoBox => Hive.box<TodoModel>('todos');
  static Box get settingsBox => Hive.box('settings');

  static Future<void> openBoxes() async {
    try {
      if (!Hive.isBoxOpen('todos')) {
        await Hive.openBox<TodoModel>('todos');
      }
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }
    } catch (e) {
      print('Error opening Hive boxes: $e');
      rethrow;
    }
  }
}
