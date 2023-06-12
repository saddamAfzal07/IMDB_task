import 'package:flutter/material.dart';
import 'package:flutter_movie_list_task/services/movies_controller.dart';
import 'package:flutter_movie_list_task/pages/favorite_screen.dart';
import 'package:get/get.dart';

import '../model/movies_model.dart';

class MovieListWidget extends StatelessWidget {
  final MovieService _movieService = Get.put(MovieService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie App'),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => FavoriteScreen());
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.favorite,
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Results>>(
        future: _movieService.getMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching movies'),
            );
          } else if (snapshot.hasData) {
            final List<Results> movies = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? 2
                          : 4,
                  mainAxisSpacing: 6.0,
                  crossAxisSpacing: 6.0,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];

                  return GestureDetector(
                    onTap: () async {
                      await _movieService.toggleFavorite(movie);
                      final String message = movie.isFavorite
                          ? 'Movie added to favorites'
                          : 'Movie removed from favorites';
                      Get.snackbar(
                        'Favorite',
                        message,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: SizedBox(
                              height: 100,
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              movie.title ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                            subtitle: Text(movie.releaseDate ?? ''),
                            trailing: Icon(
                              movie.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: movie.isFavorite ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text('No movies found'),
            );
          }
        },
      ),
    );
  }
}
