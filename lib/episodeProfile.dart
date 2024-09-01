import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'characterProfile.dart';

class EpisodeProfile extends StatefulWidget {
  final Map<String, dynamic> episode;

  const EpisodeProfile({super.key, required this.episode});

  @override
  _EpisodeProfileState createState() => _EpisodeProfileState();
}

class _EpisodeProfileState extends State<EpisodeProfile> {
  final List<Map<String, dynamic>> _characters = [];
  bool _isCharacterListVisible =
      false;

  @override
  void initState() {
    super.initState();
    _fetchCharacterData();
  }

  Future<void> _fetchCharacterData() async {
    final List<String> characterUrls =
    List<String>.from(widget.episode['characters'] ?? []);
    final List<Map<String, dynamic>> characters = [];

    final List<Future<http.Response>> requests =
    characterUrls.map((url) => http.get(Uri.parse(url))).toList();

    final List<http.Response> responses = await Future.wait(requests);

    for (var response in responses) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        characters.add(data);
      }
    }

    setState(() {
      _characters.addAll(characters);
    });
  }

  void _goToCharacterProfile(Map<String, dynamic> character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterProfile(character: character),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          formatValue(widget.episode['name']),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.lightGreen.withOpacity(0.8),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wallpaper.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.lightGreen.withOpacity(0.5),
                          spreadRadius: 6,
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      formatValue(widget.episode['name']),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC20004),
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1.0, 2.0),
                            blurRadius: 3.0,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildEpisodeDetail(
                      'Air Date', formatValue(widget.episode['air_date'])),
                  _buildEpisodeDetail(
                      'Episode', formatValue(widget.episode['episode'])),
                  _buildCharacterListToggle(),
                  _buildCharacterList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatValue(String? value) {
    return (value?.toLowerCase() == 'unknown' || value == null)
        ? 'Unknown'
        : value;
  }

  Widget _buildEpisodeDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.54),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.lightGreen.withOpacity(0.45),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$title: ',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterListToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isCharacterListVisible = !_isCharacterListVisible;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          _isCharacterListVisible
              ? 'Hide the characters'
              : 'See the characters',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterList() {
    if (!_isCharacterListVisible) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.54),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.lightGreen.withOpacity(0.45),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Characters:',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            ..._characters.map((character) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => _goToCharacterProfile(character),
                    child: Text(
                      character['name'],
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
