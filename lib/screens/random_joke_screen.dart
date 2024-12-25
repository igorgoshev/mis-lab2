import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';

class RandomJokeScreen extends StatelessWidget {
  final ApiService apiService;

  RandomJokeScreen({Key? key,
  required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke of the Day'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Joke>(
            future: apiService.getRandomJoke(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return JokeCard(
                joke: snapshot.data!,
                apiService: apiService, // Add this line
              );
            },
          ),
        ),
      ),
    );
  }
}