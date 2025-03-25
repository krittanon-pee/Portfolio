import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<int, String> genres = {}; // Store movie genres
  List<dynamic> movies = [];    // Store all movies

  @override
  void initState() {
    super.initState();
    fetchGenresAndMovies();  // Fetch genres and all movies
  }

  Future<void> fetchGenresAndMovies() async {
    final apiKey = 'd730c26d10cc8f7e17d23f3952f04f83'; // Your API Key
    final genresUrl = 'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=en-US';
    final moviesUrl = 'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey&language=en-US&page=1';

    try {
      // Fetch genres
      final genresResponse = await http.get(Uri.parse(genresUrl));
      if (genresResponse.statusCode == 200) {
        final genresData = jsonDecode(genresResponse.body);
        setState(() {
          for (var genre in genresData['genres']) {
            genres[genre['id']] = genre['name']; // Store genre_id and genre_name
          }
        });
      }

      // Fetch movies
      final moviesResponse = await http.get(Uri.parse(moviesUrl));
      if (moviesResponse.statusCode == 200) {
        final moviesData = jsonDecode(moviesResponse.body);
        setState(() {
          movies = moviesData['results']; // Store movie data
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Get movies by genre
  List<dynamic> getMoviesByGenre(int genreId) {
    return movies.where((movie) => movie['genre_ids'].contains(genreId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการภาพยนตร์'),
        backgroundColor: Colors.black87,
      ),
      body: genres.isEmpty || movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.black, // Background color
              padding: EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  int genreId = genres.keys.elementAt(index);
                  String genreName = genres[genreId] ?? 'Unknown';
                  var genreMovies = getMoviesByGenre(genreId); // Show movies by genre

                  if (genreMovies.isEmpty) {
                    return Container(); // Skip if no movies in category
                  }

                  return ExpansionTile(
                    backgroundColor: Colors.black87,
                    collapsedBackgroundColor: Colors.black87,
                    title: Text(
                      genreName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                    ),
                    children: genreMovies.map((movie) {
                      var imageUrl = 'https://image.tmdb.org/t/p/w500${movie['poster_path']}';
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailScreen(movieId: movie['id'].toString()),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.black54,
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(imageUrl, width: 100, fit: BoxFit.cover),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie['title'],
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text('Release Date: ${movie['release_date']}', style: TextStyle(color: Colors.white70)),
                                    Text('Rating: ${movie['vote_average'] ?? 'N/A'}', style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
    );
  }
}
