import 'package:hive/hive.dart';

class Task extends HiveObject {
  String title;
  String content;
  bool isDone;

  Task({
    required this.title,
    required this.content,
    this.isDone = false,
  });
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final title = reader.readString();
    final content = reader.readString();
    final isDone = reader.readBool();
    return Task(
      title: title,
      content: content,
      isDone: isDone,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeBool(obj.isDone);
  }
}
