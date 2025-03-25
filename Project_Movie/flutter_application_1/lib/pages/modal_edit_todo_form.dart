import 'package:flutter/material.dart';
import '../database/todo_item.dart';
import '../database/database_helper.dart';

class ModalEditTodoForm {
  final DatabaseHelper dbHelper;
  final TodoItem editedTodo;

  ModalEditTodoForm({required this.dbHelper, required this.editedTodo});

  Future<void> showModalInputForm(BuildContext context) {
    String title = editedTodo.title;
    String description = editedTodo.description;
    DateTime? selectedTime = editedTodo.createdAt; // Initialize with the existing time

    return showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: TextEditingController(text: title),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: description),
                onChanged: (value) {
                  description = value;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: 'Time'),
                readOnly: true, // Make it read-only
                onTap: () async {
                  // Show a time picker dialog
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedTime ?? DateTime.now()),
                  );
                  if (pickedTime != null) {
                    // Update selected time
                    selectedTime = DateTime(
                      selectedTime?.year ?? DateTime.now().year,
                      selectedTime?.month ?? DateTime.now().month,
                      selectedTime?.day ?? DateTime.now().day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  }
                },
                controller: TextEditingController(
                  text: selectedTime != null
                      ? "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                      : '',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (title.isNotEmpty && description.isNotEmpty && selectedTime != null) {
                    var updatedTodoItem = TodoItem(
                      title: title,
                      description: description,
                      isCompleted: editedTodo.isCompleted,
                      referenceId: editedTodo.referenceId,
                      createdAt: selectedTime, // Set the updated time
                    );
                    try {
                      await dbHelper.updateTodoItem(updatedTodoItem);
                      if (context.mounted) Navigator.pop(context); // Close the modal
                    } catch (e) {
                      // Handle errors if necessary
                      _showErrorDialog(context, 'Failed to update todo item: $e');
                    }
                  } else {
                    // Show an alert if fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter title, description, and select a time')),
                    );
                  }
                },
                child: const Text('Update To-Do Item'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
