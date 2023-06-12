import 'package:flutter_movie_list_task/model/movies_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MovieService extends GetxController {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = 'bcc202d4a08dddce2c569c033ae5e4ff';
  final String favoriteKey = 'favoriteMovies';
  RxBool isFavorite = false.obs;

  RxList<Results> movies = <Results>[].obs;
  final _favoriteMovies = <Results>[].obs;

  List<Results> get favoriteMovies => _favoriteMovies;
  @override
  void onInit() {
    super.onInit();
    getFavoriteMovies();
    getMovies();
  }

  Future<List<Results>> getMovies() async {
    try {
      final url =
          '$baseUrl/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiY2MyMDJkNGEwOGRkZGNlMmM1NjljMDMzYWU1ZTRmZiIsInN1YiI6IjYxMmI2ZWQ2MzliNmMzMDA0MjIzYjVlMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.uxMw39bbSTHeEn4mKNPesJENzWpkNHCsERnVFAf14m0',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List resultsData = jsonData['results'];
        final moviesData =
            resultsData.map((data) => Results.fromJson(data)).toList();
        movies.assignAll(moviesData);
        return moviesData;
      } else {
        throw Exception('Failed to fetch movies');
      }
    } catch (error) {
      throw Exception('Failed to fetch movies: $error');
    }
  }

  Future<void> saveFavoriteMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMoviesJson =
        _favoriteMovies.map((movie) => movie.toJson()).toList();
    await prefs.setString('favorite_movies', favoriteMoviesJson.toString());
  }

  Future<void> getFavoriteMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMoviesJson = prefs.getString('favorite_movies');
    if (favoriteMoviesJson != null) {
      final favoriteMoviesList =
          jsonDecode(favoriteMoviesJson) as List<dynamic>;
      _favoriteMovies.value = favoriteMoviesList
          .map((movieJson) => Results.fromJson(movieJson))
          .toList();
    }
  }

  Future<void> toggleFavorite(Results movie) async {
    movie.isFavorite = !movie.isFavorite; // Toggle the favorite flag
    if (movie.isFavorite) {
      _favoriteMovies.add(movie);
    } else {
      _favoriteMovies.remove(movie);
    }
    await saveFavoriteMovies();
  }
}
