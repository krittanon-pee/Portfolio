import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package
import '../database/booking.dart'; // Ensure this import points to your Booking model
import '../screens/ResultScreen.dart'; // Import ResultScreen

class BookingScreen extends StatefulWidget {
  final String movieId;
  final String movieTitle;

  BookingScreen({required this.movieId, required this.movieTitle});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 11, minute: 30);
  List<bool> selectedSeats = List.generate(70, (index) => false);
  TextEditingController phoneController = TextEditingController();
  int totalPrice = 0;
  bool isLoading = false; // Loading state

  final RegExp phoneRegExp = RegExp(r'^\d{10}$');
  final int normalSeatPrice = 160;
  final int honeymoonSeatPrice = 180;

  List<TimeOfDay> showtimes = [
    const TimeOfDay(hour: 11, minute: 30),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 19, minute: 0),
  ];

  // This function formats the TimeOfDay to a string in HH:mm format
  String formatTime(TimeOfDay time) {
    final formattedHour = time.hour < 10 ? '0${time.hour}' : '${time.hour}';
    final formattedMinute = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    return '$formattedHour:$formattedMinute';
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _updateTotalPrice() {
    totalPrice = selectedSeats.asMap().entries.fold(0, (sum, entry) {
      int index = entry.key;
      if (entry.value) {
        return sum + (index ~/ 7 < 2 ? honeymoonSeatPrice : normalSeatPrice);
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จองตั๋วหนัง'),
      ),
      body: isLoading // Show loading indicator if booking is in progress
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Phone Number Input
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'โปรดระบุเบอร์โทรศัพท์ 10 หลัก',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Date Picker
                ListTile(
                  title: Text('เลือกวันที่: ${DateFormat.yMMMd().format(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                // Time Picker
                DropdownButton<TimeOfDay>(
                  value: selectedTime,
                  onChanged: (TimeOfDay? newValue) {
                    setState(() {
                      selectedTime = newValue!;
                    });
                  },
                  items: showtimes.map<DropdownMenuItem<TimeOfDay>>((TimeOfDay time) {
                    return DropdownMenuItem<TimeOfDay>(
                      value: time,
                      child: Text(formatTime(time)), // Use the custom format function
                    );
                  }).toList(),
                ),
                // Seat Layout
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: List.generate(10, (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(7, (index) {
                          int seatIndex = row * 7 + index;
                          String seatLabel = '${String.fromCharCode(65 + row)}${index + 1}';
                          bool isHoneymoonZone = row < 2;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSeats[seatIndex] = !selectedSeats[seatIndex];
                                _updateTotalPrice(); // Update total price
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                color: selectedSeats[seatIndex]
                                    ? Colors.green
                                    : isHoneymoonZone
                                        ? Colors.pink[100]
                                        : Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              width: 50,
                              height: 50,
                              child: Center(
                                child: Text(seatLabel, style: const TextStyle(color: Colors.black)),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
                // Total Price Display
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'ราคาทั้งหมด: \$${totalPrice}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Seat Type Legend
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(width: 20, height: 20, color: Colors.pink[100]),
                          const SizedBox(width: 8),
                          const Text('Honeymoon Seat'),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 20, height: 20, color: Colors.blue[100]),
                          const SizedBox(width: 8),
                          const Text('Normal Seat'),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (phoneController.text.isEmpty || !phoneRegExp.hasMatch(phoneController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('โปรดระบุเบอร์โทรศัพท์ 10 หลัก')),
                      );
                      return;
                    }

                    // Collect booked seat labels
                    List<String> bookedSeats = [];
                    for (int i = 0; i < selectedSeats.length; i++) {
                      if (selectedSeats[i]) {
                        int row = i ~/ 7; // Determine the row (0-9 for A-J)
                        int seatIndex = i % 7; // Determine the seat index (0-6)
                        String seatLabel = '${String.fromCharCode(65 + row)}${seatIndex + 1}'; // Generate seat label
                        bookedSeats.add(seatLabel); // Add seat label
                      }
                    }

                    // Create booking entry
                    Booking booking = Booking(
                      movieId: widget.movieId,
                      movieTitle: widget.movieTitle,
                      tickets: bookedSeats.length,
                      phoneNumber: phoneController.text,
                      bookingDate: Timestamp.fromDate(selectedDate),
                      bookingTime: Timestamp.fromDate(DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute)),
                      seats: bookedSeats,
                      totalPrice: totalPrice,
                    );

                    setState(() {
                      isLoading = true; // Start loading
                    });

                    try {
                      await DbHelper.addBooking(booking);

                      if (!mounted) return;

                      // Navigate to ResultScreen after booking
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(booking: booking),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ไม่สามารถจองได้: $e')),
                      );
                    } finally {
                      setState(() {
                        isLoading = false; // Stop loading
                      });
                    }
                  },
                  child: const Text('จองที่นั่งสำเร็จ'),
                ),
              ],
            ),
    );
  }
}

// Firestore Database Helper class (example)
class DbHelper {
  static Future<void> addBooking(Booking booking) async {
    await FirebaseFirestore.instance.collection('bookings').add(booking.toMap());
  }
}