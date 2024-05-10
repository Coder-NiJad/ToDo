import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDo {
  String? id;
  String? todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'Morning Exercise', isDone: true),
      ToDo(id: '02', todoText: 'Buy Groceries', isDone: true),
      ToDo(id: '03', todoText: 'Check Emails', isDone: false),
      ToDo(id: '04', todoText: 'Team Meeting', isDone: false),
      ToDo(id: '05', todoText: 'Work on Mobile Apps', isDone: false),
      ToDo(id: '06', todoText: 'Dinner with Jenny', isDone: false),
    ];
  }

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
    };
  }
}

class TodoProvider extends ChangeNotifier {
  late final List<ToDo> _todos;
  List<ToDo> _filteredTodoList = [];

  TodoProvider() {
    final todoInstance = ToDo(id: null, todoText: null);
    _todos = todoInstance.todoList();
  }
  List<ToDo> get todos => _filteredTodoList.isNotEmpty ? _filteredTodoList : _todos;

  void toggleTodoStatus(ToDo todo) {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index != -1) {
      _todos[index].isDone = !_todos[index].isDone;
      notifyListeners();
    }
  }

  void addTodo(String todoText) {
    final newTodo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      todoText: todoText,
    );
    _todos.add(newTodo);
    notifyListeners();
  }

  Future<void> _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todoList', jsonEncode(_todos));
  }

  Future<void> loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = prefs.getString('todoList');
    if (todoListJson != null) {
      _todos.clear();
      _todos.addAll(jsonDecode(todoListJson).map<ToDo>((item) => ToDo.fromJson(item)).toList());
      notifyListeners();
    }
  }

  void editTodo(ToDo todo, String newText) {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index != -1) {
      _todos[index].todoText = newText;
      _saveTodoList();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((item) => item.id == id);
    _saveTodoList();
    notifyListeners();
  }

  void handleToDo(ToDo todo) {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index != -1) {
      _todos[index].isDone = !_todos[index].isDone;
      _saveTodoList();
      notifyListeners();
    }
  }

  void filterTodos(String keyword) {
    _filteredTodoList = _todos.where((item) => item.todoText != null && item.todoText!.toLowerCase().contains(keyword.toLowerCase())).toList();
    notifyListeners();
  }

  void resetFilter() {
    _filteredTodoList.clear();
    notifyListeners();
  }
}
