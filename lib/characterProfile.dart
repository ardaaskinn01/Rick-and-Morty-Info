import 'package:flutter/material.dart';
import 'package:rick_and_morty_mobile/locationProfile.dart';

class CharacterProfile extends StatelessWidget {
  final Map<String, dynamic> character;

  const CharacterProfile({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          formatValue(character['name']),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.green.withOpacity(0.8),
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
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      formatValue(character['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          spreadRadius: 6,
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      formatValue(character['name']),
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
                  _buildCharacterDetail(
                      'Status', formatValue(character['status'])),
                  _buildCharacterDetail(
                      'Species', formatValue(character['species'])),
                  _buildCharacterDetail(
                      'Gender', formatValue(character['gender'])),
                  _buildNavigableDetail(
                      context, 'Origin', character['origin']),
                  _buildNavigableDetail(
                      context, 'Location', character['location']),
                  _buildCharacterDetail(
                    'Total Episodes',
                    character['episode'] != null &&
                        character['episode'].isNotEmpty
                        ? character['episode'].length.toString()
                        : 'Unknown',
                  ),
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

  Widget _buildCharacterDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.54),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.45),
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

  Widget _buildNavigableDetail(BuildContext context, String title, Map<String, dynamic>? detail) {
    if (detail == null || detail['name'] == null || detail['url'] == null) {
      return _buildCharacterDetail(title, 'Unknown');
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationProfile(location: detail),
          ),
        );
      },
      child: _buildCharacterDetail(title, formatValue(detail['name'])),
    );
  }
}