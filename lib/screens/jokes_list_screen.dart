import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';

class JokesListScreen extends StatelessWidget {
  final String jokeType;
  final ApiService apiService = ApiService();

  JokesListScreen({
    Key? key,
    required this.jokeType,
  }) : super(key: key);

  String get displayType {
    return jokeType.split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$displayType Jokes'),
      ),
      body: FutureBuilder<List<Joke>>(
        future: apiService.getJokesByType(jokeType),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return JokeCard(joke: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}