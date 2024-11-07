import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureCharacters;

  @override
  void initState() {
    super.initState();
    futureCharacters = fetchCharacters();
  }

  Future<List<dynamic>> fetchCharacters() async {
    final response =
        await http.get(Uri.parse('https://api.disneyapi.dev/character'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<dynamic>>(
        // setup the URL for your API here
        future: futureCharacters,
        builder: (context, snapshot) {
          // Consider 3 cases here
          // when the process is ongoing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          // return CircularProgressIndicator();

          // if an error occurs
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Use the library here
          // when the process is completed:
          // successful
          if (snapshot.hasData) {
            final characters = snapshot.data;

            return ExpandedTileList.builder(
              itemCount: characters!.length,
              itemBuilder: (context, index, controller) {
                final character = characters[index];

                final imageUrl = character['imageUrl'] ?? '';
                final name = character['name'] ?? 'Unknown';
                final description =
                    character['description'] ?? 'No description';
                return ExpandedTile(
                  controller: controller,
                  title: Row(
                    children: [
                      if (imageUrl.isNotEmpty)
                        CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 24,
                        ),
                      const SizedBox(width: 20),
                      Text(name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (description.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(description)),
                      Text(
                          'Films: ${character['films']?.join(', ') ?? 'No films listed'}'),
                      Text(
                          'TV Shows: ${character['tvShows']?.join(', ') ?? 'No shows listed'}'),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
