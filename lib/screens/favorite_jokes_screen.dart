import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';

class FavoriteJokesScreen extends StatelessWidget {
  final ApiService apiService;

  const FavoriteJokesScreen({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Jokes'),
      ),
      body: FutureBuilder<List<Joke>>(
        future: apiService.getFavoriteJokes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite jokes yet!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return JokeCard(
                joke: snapshot.data![index],
                apiService: apiService,
              );
            },
          );
        },
      ),
    );
  }
}