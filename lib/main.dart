import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/todo_model.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'utils/hive_boxes.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TodoModelAdapter());

    // Open boxes with error handling
    await HiveBoxes.openBoxes();

    // Initialize notifications (non-blocking)
    NotificationService.initialize().catchError((error) {
      debugPrint('Notification initialization failed: $error');
    });
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isInitialized = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  void _checkInitialization() async {
    try {
      // Wait a bit to ensure Hive is ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if boxes are open
      if (Hive.isBoxOpen('settings')) {
        setState(() {
          _isInitialized = true;
        });
      } else {
        // Try to open boxes again
        await HiveBoxes.openBoxes();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Initialization Error'),
              const SizedBox(height: 8),
              Text(_error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = '';
                    _isInitialized = false;
                  });
                  _checkInitialization();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, box, widget) {
        final isDarkMode = box.get('isDarkMode', defaultValue: false);
        final userName = box.get('userName', defaultValue: '');

        return MaterialApp(
          title: 'Modern ToDo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              color: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: userName.isEmpty ? WelcomeScreen() : const HomeScreen(),
        );
      },
    );
  }
}
