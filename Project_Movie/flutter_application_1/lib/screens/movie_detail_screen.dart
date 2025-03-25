import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/seat_booking_screen.dart'; // ตรวจสอบเส้นทาง
import 'package:url_launcher/url_launcher.dart';

class MovieDetailScreen extends StatelessWidget {
  final String movieId;

  MovieDetailScreen({required this.movieId});

  // ฟังก์ชันดึงข้อมูลหนัง
  Future<Map<String, dynamic>> fetchMovieDetails() async {
    final apiKey = 'd730c26d10cc8f7e17d23f3952f04f83'; // ใส่ API Key ของคุณ
    final url = 'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('ไม่สามารถอธิบายหนังได้ ');
    }
  }

  // ฟังก์ชันดึงวิดีโอ (trailer) ของหนัง
  Future<List<dynamic>> fetchMovieVideos() async {
    final apiKey = 'd730c26d10cc8f7e17d23f3952f04f83'; // ใส่ API Key ของคุณ
    final url = 'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('ไม่สามารถโหลดวีดีโอหนังได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดหนัง'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var movie = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงภาพโปสเตอร์ของหนัง
                Image.network(
                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}', // ใช้ URL ของภาพโปสเตอร์
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text('ชื่อเรือง: ${movie['title']}', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Text('คำอธิบาย: ${movie['overview']}'),
                const SizedBox(height: 10),
                Text('วันที่เปิดตัว: ${movie['release_date']}'),
                const SizedBox(height: 10),
                movie['runtime'] != null
                    ? Text('Runtime: ${movie['runtime']} minutes')
                    : const SizedBox(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // นำทางไปยังหน้าจองที่นั่ง
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(movieId: movieId, movieTitle: movie['title']),
                      ),
                    );
                  },
                  child: const Text('จองตั๋วหนัง'),
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<dynamic>>(
                  future: fetchMovieVideos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    var videos = snapshot.data!;
                    if (videos.isEmpty) {
                      return const Text('ไม่มี Trailer สำหรับหนังนี้');
                    }

                    // สมมุติว่าผลลัพธ์แรกคือวิดีโอตัวอย่าง
                    var trailer = videos[0]; 
                    final videoUrl = 'https://www.youtube.com/watch?v=${trailer['key']}';
                    return ElevatedButton(
                      onPressed: () async {
                        Uri uri = Uri.parse(videoUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch $videoUrl')),
                          );
                        }
                      },
                      child: const Text('ดู Trailer'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}