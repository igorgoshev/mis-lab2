import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/api_services.dart';

class JokeCard extends StatefulWidget {
  final Joke joke;
  final ApiService apiService;

  const JokeCard({
    Key? key,
    required this.joke,
    required this.apiService,
  }) : super(key: key);

  @override
  State<JokeCard> createState() => _JokeCardState();
}

class _JokeCardState extends State<JokeCard> {
  bool? _isFavorite;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFav = await widget.apiService.isFavorite(widget.joke.id.toString());
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      // Handle error gracefully
      if (mounted) {
        setState(() {
          _isFavorite = false; // Default to not favorite in case of an error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.joke.setup,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: _isFavorite == null
                      ? const CircularProgressIndicator() // Show a loader while loading
                      : Icon(
                    _isFavorite! ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite! ? Colors.red : null,
                  ),
                  onPressed: _isFavorite == null
                      ? null // Disable button while loading
                      : () async {
                    if (_isFavorite!) {
                      await widget.apiService.removeFromFavorites(widget.joke.id);
                    } else {
                      await widget.apiService.addToFavorites(widget.joke);
                    }
                    await _checkFavoriteStatus();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.joke.punchline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
