import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/booking.dart'; // Ensure this import points to your Booking model
import '../screens/home_screen.dart'; // Import HomeScreen

class ResultScreen extends StatelessWidget {
  final Booking booking;

  ResultScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การจองสำเร็จเรียบร้อย'),
        backgroundColor: Colors.redAccent, // Movie-themed color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ชื่อหนัง: ${booking.movieTitle}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            Text(
              'วันที่จอง: ${booking.getFormattedBookingDate().split(' ')[0]}', // ใช้ฟังก์ชันจัดรูปแบบวันที่
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              'เวลาที่จอง: ${booking.getFormattedBookingTime()}', // ใช้ฟังก์ชันจัดรูปแบบเวลา
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              'เบอร์โทรศัพท์: ${booking.phoneNumber}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              'ที่นั่ง: ${booking.seats.join(', ')}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              'ราคาที่ต้องจ่าย: \$${booking.totalPrice}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen()), // Ensure HomeScreen is instantiated
                  );
                },
                style: ElevatedButton.styleFrom(

                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('กลับสู่หน้าหลัก'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
