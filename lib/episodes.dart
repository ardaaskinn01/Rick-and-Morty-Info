import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rick_and_morty_mobile/episodeProfile.dart';

class EpisodesPage extends StatefulWidget {
  const EpisodesPage({super.key});

  @override
  _EpisodesPageState createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  int currentPage = 1;
  int totalPages = 3;
  String? filterName;
  String? filterEpisode;

  late TextEditingController nameController;
  late TextEditingController episodeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: filterName);
    episodeController = TextEditingController(text: filterEpisode);
  }

  Future<Map<String, dynamic>> _fetchEpisodes(int page) async {
    final filters = {
      if (filterName != null && filterName!.isNotEmpty) 'name': filterName,
      if (filterEpisode != null && filterEpisode!.isNotEmpty)
        'episode': filterEpisode,
    };

    final queryString = filters.isNotEmpty
        ? filters.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value!)}')
            .join('&')
        : '';

    final response = await http.get(Uri.parse(
        'https://rickandmortyapi.com/api/episode?page=$page${queryString.isNotEmpty ? '&$queryString' : ''}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  void _applyFilters() async {
    currentPage = 1;

    final data = await _fetchEpisodes(currentPage);

    setState(() {
      totalPages = data['info']['pages'] ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Episodes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.lightGreenAccent.withOpacity(0.8),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wallpaper.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color:
                  Colors.black.withOpacity(0.5),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fetchEpisodes(currentPage),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData ||
                        (snapshot.data!['results'] as List<dynamic>).isEmpty) {
                      return const Center(
                        child: Text(
                          'No episodes found matching the filters.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      );
                    } else {
                      var episodes = snapshot.data!['results'] as List<dynamic>;
                      totalPages = snapshot.data!['info']['pages'] ?? 7;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.9,
                          ),
                          itemCount: episodes.length,
                          itemBuilder: (context, index) {
                            var episode = episodes[index];
                            return _buildEpisodeCard(episode, context);
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                color: Colors.lightGreenAccent.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: currentPage > 1
                          ? () {
                              setState(() {
                                currentPage--;
                              });
                            }
                          : null,
                    ),
                    DropdownButton<int>(
                      value: currentPage,
                      items: List.generate(totalPages, (index) => index + 1)
                          .map((page) {
                        return DropdownMenuItem<int>(
                          value: page,
                          child: Text('Page $page'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            currentPage = newValue;
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages
                          ? () {
                              setState(() {
                                currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightGreenAccent.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'Filter Episodes',
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterName = value;
                  },
                ),
                TextField(
                  controller: episodeController,
                  decoration: const InputDecoration(
                    labelText: 'Episode',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterEpisode = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Apply Filters',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                setState(() {
                  filterName =
                      nameController.text.isEmpty ? null : nameController.text;
                  filterEpisode = episodeController.text.isEmpty
                      ? null
                      : episodeController.text;
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEpisodeCard(dynamic episode, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpisodeProfile(
                episode:
                    episode),
          ),
        );
      },
      child: Card(
        color: Colors.white.withOpacity(0.18),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                episode['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFD6368),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Air Date: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: episode['air_date'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              RichText(
                text: TextSpan(
                  text: 'Episode: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: episode['episode'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              RichText(
                text: TextSpan(
                  text: 'Characters: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: episode['characters'] != null
                          ? episode['characters'].length.toString()
                          : 'Unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
