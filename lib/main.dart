import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/task.dart';

const String kTasksBoxName = 'tasksBox';
const String kNotificationsPrefKey = 'enable_task_reminders';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>(kTasksBoxName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List & Settings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _remindersEnabled = false;
  bool _prefsLoaded = false;
  late SharedPreferences _prefs;

  late Box<Task> _tasksBox;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tasksBox = Hive.box<Task>(kTasksBoxName);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = _prefs.getBool(kNotificationsPrefKey) ?? false;
      _prefsLoaded = true;
    });
  }

  Future<void> _onReminderToggle(bool value) async {
    setState(() => _remindersEnabled = value);
    await _prefs.setBool(kNotificationsPrefKey, value);
  }

  void _addTask() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final task = Task(title: title, content: content);
    _tasksBox.add(task);

    _titleController.clear();
    _contentController.clear();
    setState(() {});
  }

  void _deleteTask(int index) {
    final task = _tasksBox.getAt(index);
    task?.delete();
    setState(() {});
  }

  void _toggleTaskDone(int index) {
    final task = _tasksBox.getAt(index);
    if (task != null) {
      task.isDone = !task.isDone;
      task.save();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List & Settings'),
      ),
      body: !_prefsLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('APP SETTINGS'),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Enable Task Reminders'),
                    value: _remindersEnabled,
                    onChanged: _onReminderToggle,
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('MY TASKS'),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Enter task title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Enter task description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('ADD TASK'),
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<Box<Task>>(
                  valueListenable: _tasksBox.listenable(),
                  builder: (context, box, _) {
                    if (box.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child:
                            Center(child: Text('No tasks yet. Add one above!')),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final task = box.getAt(index)!;
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isDone,
                              onChanged: (_) => _toggleTaskDone(index),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: task.content.isNotEmpty
                                ? Text(task.content)
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
