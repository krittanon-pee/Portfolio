import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/todo_item.dart'; // Ensure this is the correct import

class ModalTodoForm {
  final DatabaseHelper dbHelper;

  ModalTodoForm({required this.dbHelper});

  Future<void> showModalInputForm(BuildContext context) {
    String title = '';
    String description = '';
    DateTime? selectedTime; // Variable to store selected time

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
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: 'Time'),
                readOnly: true, // Make it read-only
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    // Convert TimeOfDay to DateTime
                    selectedTime = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
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
                    var newTodoItem = TodoItem(
                      title: title,
                      description: description,
                      createdAt: selectedTime!, // Use selected time
                    );
                    await dbHelper.insertTodoItem(newTodoItem);
                    Navigator.pop(context); // Close the modal
                  } else {
                    // Show an alert if fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter title, description, and select a time')),
                    );
                  }
                },
                child: const Text('Add To-Do Item'),
              ),
            ],
          ),
        );
      },
    );
  }
}
