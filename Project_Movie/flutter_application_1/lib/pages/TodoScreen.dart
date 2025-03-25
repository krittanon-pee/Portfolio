import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';
import '../database/todo_item.dart'; // Import TodoItem model
import '../pages/modal_todo_form.dart';
import '../pages/modal_edit_todo_form.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class TodoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const TodoScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoItem> todoItems = []; // Change to TodoItem

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Background color
      appBar: AppBar(
        title: const Text('What\'s up, User!',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () async {
              await ModalTodoForm(dbHelper: widget.dbHelper)
                  .showModalInputForm(context);
              setState(() {}); // Refresh after adding
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            widget.dbHelper.getStream(), // Use the stream from DatabaseHelper
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Map Firestore documents to TodoItem objects
          todoItems = snapshot.data!.docs
              .map((doc) => TodoItem.fromSnapshot(doc))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Tasks',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '${todoItems.length} tasks',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: todoItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0), // Space between cards
                        elevation: 4, // Shadow effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                              16.0), // Padding inside ListTile
                          title: Text(
                            todoItems[index].title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ), // Use TodoItem title
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todoItems[index].description,
                                style: const TextStyle(color: Colors.grey),
                              ), // Use TodoItem description
                              const SizedBox(
                                  height:
                                      4), // Space between description and time
                              Text(
                                DateFormat('h:mm a').format(todoItems[index]
                                    .createdAt), // Format and show time
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Checkbox(
                            value: todoItems[index].isCompleted,
                            activeColor: Colors.teal,
                            onChanged: (value) async {
                              setState(() {
                                todoItems[index].isCompleted =
                                    value!; // Update local state
                              });
                              await widget.dbHelper.updateTodoItem(
                                  todoItems[index]); // Update Firestore
                            },
                          ),
                          onLongPress: () async {
                            await ModalEditTodoForm(
                              dbHelper: widget.dbHelper,
                              editedTodo:
                                  todoItems[index], // Pass the actual TodoItem
                            ).showModalInputForm(context);
                            setState(() {}); // Refresh after editing
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ModalTodoForm(dbHelper: widget.dbHelper)
              .showModalInputForm(context);
          setState(() {}); // Refresh after adding
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
