# To-Do List & Settings App (Flutter)

Matches "Task Session 5": combines **SharedPreferences** (settings) and
**Hive** (task persistence, with a manual `TypeAdapter`).

## Features

1. **SharedPreferences (Settings)**
   - "Enable Task Reminders" switch on the Settings section.
   - State is saved with `setBool` and restored on app restart with `getBool`.

2. **Hive (Tasks Persistence)**
   - Custom `Task` model (`lib/models/task.dart`) with `title`, `content`, `isDone`.
   - **Manual** `TaskAdapter` (no `build_runner` / code generation) implementing
     `read()` / `write()` by hand.
   - Tasks are added, listed, checked off, and deleted, all persisted in a Hive box.

## Project structure

```
todo_hive_app/
├── lib/
│   ├── main.dart          # UI + SharedPreferences + Hive wiring
│   └── models/
│       └── task.dart      # Task model + manual TypeAdapter
├── pubspec.yaml
└── README.md
```

## How to run

1. Make sure Flutter is installed: `flutter --version`
2. From the project folder:
   ```bash
   flutter pub get
   flutter run
   ```

That's it — no `build_runner` step is needed since the `TypeAdapter` is written
by hand instead of generated.

## Notes

- `Hive.registerAdapter(TaskAdapter())` and `Hive.openBox<Task>('tasksBox')`
  happen once in `main()` before `runApp()`.
- The task list UI wraps the Hive box in a `ValueListenableBuilder`, so the
  list rebuilds automatically whenever a task is added, toggled, or deleted —
  no manual `setState` bookkeeping needed for the list itself.
