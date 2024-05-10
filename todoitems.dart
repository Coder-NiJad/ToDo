import 'package:flutter/material.dart';
import 'package:mystic_todo/todo.dart';


class ToDoItem extends StatefulWidget {
  final ToDo todo;
  final onToDoChanged;
  final onDeleteItem;
  final onEditItem;

  const ToDoItem({super.key, required this.todo, this.onToDoChanged, this.onDeleteItem, required this.onEditItem});

  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.todo.todoText);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit To-Do'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                widget.onEditItem(widget.todo, newText); // Pass the todo instance and newText
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          widget.onToDoChanged(widget.todo);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          widget.todo.isDone ? Icons.check_box_sharp : Icons.check_box_outline_blank_sharp,
          color: Colors.green,
        ),
        title: Text(
          widget.todo.todoText!,
          style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
              decoration: widget.todo.isDone ? TextDecoration.lineThrough : null),
        ),
        trailing: Container(
          height: 40,
          width: 100,
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  color: Colors.black,
                  iconSize: 22,
                  onPressed: () {
                    _showEditDialog(context);
                  },
                  icon: const Icon(Icons.edit_sharp)),
              IconButton(
                  color: Colors.black,
                  iconSize: 22,
                  onPressed: () {
                    widget.onDeleteItem(widget.todo.id);
                  },
                  icon: const Icon(Icons.delete_sharp)),
            ],
          ),
        ),
      ),
    );
  }
}
