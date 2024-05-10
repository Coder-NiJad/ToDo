import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo {
  String id;
  String? todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  ToDo.fromFirestore(DocumentSnapshot doc)
      : id = doc.id,
        todoText = doc['todoText'],
        isDone = doc['isDone'];

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
  final List<ToDo> _todos = [];
  List<ToDo> _filteredTodoList = [];
  late final StreamSubscription<QuerySnapshot> todosSubscription;

  TodoProvider() {
    startListeningToTodosUpdates();
    fetchTodosFromFirestore();
  }

  List<ToDo> get todos => _filteredTodoList.isNotEmpty ? _filteredTodoList : _todos;

  Future<void> fetchTodosFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('todos').orderBy('id').get();
    final todoList = querySnapshot.docs.map((doc) => ToDo.fromFirestore(doc)).toList();
    _todos.addAll(todoList);
    notifyListeners();
  }

  void startListeningToTodosUpdates() {
    todosSubscription = FirebaseFirestore.instance
        .collection('todos')
        .orderBy('id')
        .snapshots()
        .listen((querySnapshot) {
      final todoList = querySnapshot.docs.map((doc) => ToDo.fromFirestore(doc)).toList();
      _todos.clear();
      _todos.addAll(todoList);
      notifyListeners();
    });
  }

  Future<void> addTodo(String todoText) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = Random().nextInt(900000) + 100000;
    final id = '$timestamp$randomValue';

    final newTodo = ToDo(id: id, todoText: todoText);
    await FirebaseFirestore.instance.collection('todos').doc(id).set(newTodo.toJson());
    notifyListeners();
  }

  Future<void> editTodo(ToDo todo, String newText) async {
    await FirebaseFirestore.instance.collection('todos').doc(todo.id).update({'todoText': newText});
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).delete();
    notifyListeners();
  }

  Future<void> handleToDo(ToDo todo) async {
    final updatedTodo = ToDo(id: todo.id, todoText: todo.todoText, isDone: !todo.isDone);
    await FirebaseFirestore.instance.collection('todos').doc(todo.id).update(updatedTodo.toJson());
    notifyListeners();
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
