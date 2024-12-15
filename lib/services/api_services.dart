import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/joke.dart';

class ApiService {
  static const String baseUrl = 'https://official-joke-api.appspot.com';

  Future<List<String>> getJokeTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/types'));
      if (response.statusCode == 200) {
        List<dynamic> types = json.decode(response.body);
        return types.map((type) => type.toString()).toList();
      }
      throw Exception('Failed to load joke types');
    } catch (e) {
      return ['general', 'knock-knock', 'programming']; // Fallback types
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
}