import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/joke.dart';

class ApiService {
  static const String baseUrl = 'https://official-joke-api.appspot.com';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'default_user';

  Future<List<String>> getJokeTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/types'));
      if (response.statusCode == 200) {
        List<dynamic> types = json.decode(response.body);
        return types.map((type) => type.toString()).toList();
      }
      throw Exception('Failed to load joke types');
    } catch (e) {
      return ['general', 'knock-knock', 'programming'];
    }
  }

  Future<List<Joke>> getJokesByType(String type) async {
    final response = await http.get(Uri.parse('$baseUrl/jokes/$type/ten'));
    if (response.statusCode == 200) {
      List<dynamic> jokes = json.decode(response.body);
      return jokes.map((joke) => Joke.fromJson(joke)).toList();
    }
    throw Exception('Failed to load jokes');
  }

  Future<Joke> getRandomJoke() async {
    final response = await http.get(Uri.parse('$baseUrl/random_joke'));
    if (response.statusCode == 200) {
      return Joke.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load random joke');
  }

  // Firestore favorites methods
  Future<void> addToFavorites(Joke joke) async {
    await _firestore.collection('favorite_jokes').doc('${userId}_${joke.id}').set({
      'jokeId': joke.id,
      'type': joke.type,
      'setup': joke.setup,
      'punchline': joke.punchline,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFromFavorites(int jokeId) async {
    await _firestore.collection('favorite_jokes').doc('${userId}_$jokeId').delete();
  }

  Future<bool> isFavorite(String jokeId) async {
    try {
      final documentSnapshot =
      await _firestore.collection('favorite_jokes').doc('${userId}_$jokeId').get();
      return documentSnapshot.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<List<Joke>> getFavoriteJokes() async {
    final querySnapshot = await _firestore
        .collection('favorite_jokes')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Joke(
        id: data['jokeId'],
        type: data['type'],
        setup: data['setup'],
        punchline: data['punchline'],
      );
    }).toList();
  }
}
