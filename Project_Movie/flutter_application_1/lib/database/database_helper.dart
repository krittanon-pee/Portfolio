import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking.dart';

class DatabaseHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new booking
  Future<void> addBooking(Booking booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  // Retrieve all bookings
  Future<List<Booking>> getBookings() async {
    QuerySnapshot snapshot = await _db.collection('bookings').get();
    return snapshot.docs.map((doc) => Booking.fromDocument(doc)).toList();
  }

  // You can add more methods for updating and deleting bookings as needed
}
