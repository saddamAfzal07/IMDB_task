import 'package:flutter/material.dart';
import 'package:flutter_movie_list_task/model/movies_model.dart';
import 'package:get/get.dart';

import '../services/movies_controller.dart';

class FavoriteScreen extends StatelessWidget {
  final MovieService _movieService = Get.put(MovieService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Movies'),
      ),
      body: Obx(
        () {
          final List<Results> favoriteMovies = _movieService.favoriteMovies;

          if (favoriteMovies.isEmpty) {
            return const Center(
              child: Text('No favorite movies'),
            );
          } else {
            return ListView.builder(
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];

                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  title: Text(movie.title ?? ''),
                  subtitle: Text(movie.releaseDate ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite),
                    color: Colors.red,
                    onPressed: () {
                      _movieService.toggleFavorite(movie);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
