import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  static const String collectionName = 'todoItems';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colIsCompleted = 'isCompleted';
  static const String colCreatedAt = 'createdAt'; // New field for creation time

  final String title;
  final String description;
  bool isCompleted;
  final String? referenceId;
  final DateTime createdAt; // New field to store creation time

  TodoItem({
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.referenceId,
    DateTime? createdAt, // Optional parameter
  }) : createdAt = createdAt ?? DateTime.now(); // Default to now if not provided

  Map<String, dynamic> toJson() {
    return {
      colTitle: title,
      colDescription: description,
      colIsCompleted: isCompleted,
      colCreatedAt: createdAt.toIso8601String(), // Serialize DateTime to String
    };
  }

  factory TodoItem.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TodoItem(
      title: data[colTitle] ?? '',
      description: data[colDescription] ?? '',
      isCompleted: data[colIsCompleted] ?? false,
      referenceId: snapshot.id,
      createdAt: DateTime.parse(data[colCreatedAt] ?? DateTime.now().toIso8601String()), // Parse DateTime
    );
  }
}
