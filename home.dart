import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mystic_todo/authentication.dart';
import 'package:mystic_todo/todo.dart';
import 'package:mystic_todo/todoitems.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _toDoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<TodoProvider>(context, listen: false).loadTodoList();
  }

  logOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, toDoListProviderModel, child) => Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    searchBox(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ListView(
                          children: [
                            const SizedBox(height: 20),
                            for (ToDo todo in toDoListProviderModel.todos.reversed)
                              ToDoItem(
                                todo: todo,
                                onToDoChanged: toDoListProviderModel.handleToDo,
                                onDeleteItem: toDoListProviderModel.deleteTodo,
                                onEditItem: toDoListProviderModel.editTodo,
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _toDoController,
                        decoration: const InputDecoration(
                          hintText: 'Add a new task',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        toDoListProviderModel.addTodo(_toDoController.text);
                        _toDoController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white70,
                        minimumSize: const Size(60, 60),
                        elevation: 10,
                        shape: const CircleBorder(),
                      ),
                      child: const Text(
                        '+',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.black54,
            size: 25,
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.black54,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.indigoAccent,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: const Text(
              ' ToDo List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            child: InkWell(
              onTap: () {
                logOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthenticationPage()));
              },
              child: const CircleAvatar(
                backgroundImage: AssetImage("assets/images/profile.png"),
                backgroundColor: Colors.indigoAccent,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      context.read<TodoProvider>().resetFilter();
    } else {
      context.read<TodoProvider>().filterTodos(enteredKeyword);
    }
  }
}
