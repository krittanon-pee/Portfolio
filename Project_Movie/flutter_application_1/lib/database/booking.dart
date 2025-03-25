import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String movieId;
  final String movieTitle;
  final String phoneNumber;
  final int tickets;
  final List<String> seats;
  final int totalPrice;
  final Timestamp bookingDate;
  final Timestamp bookingTime;

  Booking({
    required this.movieId,
    required this.movieTitle,
    required this.phoneNumber,
    required this.tickets,
    required this.seats,
    required this.totalPrice,
    required this.bookingDate,
    required this.bookingTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "01_movieId": movieId,
      "02_movieTitle": movieTitle,
      "03_phoneNumber": phoneNumber,
      "04_tickets": tickets,
      "05_seats": seats,
      "06_totalPrice": totalPrice,
      "07_bookingDate": bookingDate,
      "08_bookingTime": bookingTime,
    };
  }

  factory Booking.fromDocument(DocumentSnapshot doc) {
    return Booking(
      movieId: doc['01_movieId'] ?? '',
      movieTitle: doc['02_movieTitle'] ?? '',
      tickets: doc['04_tickets'] ?? 0,
      phoneNumber: doc['03_phoneNumber'] ?? '',
      bookingDate: doc['07_bookingDate'] ?? Timestamp.now(),
      bookingTime: doc['08_bookingTime'] ?? Timestamp.now(),
      seats: List<String>.from(doc['05_seats'] ?? []),
      totalPrice: doc['06_totalPrice'] ?? 0,
    );
  }

  // ฟังก์ชันเพื่อจัดรูปแบบวันที่
  String getFormattedBookingDate() {
    DateTime date = bookingDate.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ฟังก์ชันเพื่อจัดรูปแบบเวลา
  String getFormattedBookingTime() {
    DateTime time = bookingTime.toDate();
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
