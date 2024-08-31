import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'characterProfile.dart';

class CharactersPage extends StatefulWidget {
  @override
  _CharactersPageState createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  int currentPage = 1;
  int totalPages = 42;
  String? filterName;
  String? filterStatus;
  String? filterSpecies;
  String? filterGender;
  String? filterType;

  late TextEditingController nameController;
  late TextEditingController statusController;
  late TextEditingController speciesController;
  late TextEditingController genderController;
  late TextEditingController typeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: filterName);
    statusController = TextEditingController(text: filterStatus);
    speciesController = TextEditingController(text: filterSpecies);
    genderController = TextEditingController(text: filterGender);
    typeController = TextEditingController(text: filterType);
  }

  Future<Map<String, dynamic>> _fetchCharacters(int page) async {
    final filters = {
      if (filterName != null && filterName!.isNotEmpty) 'name': filterName,
      if (filterStatus != null && filterStatus!.isNotEmpty) 'status': filterStatus,
      if (filterSpecies != null && filterSpecies!.isNotEmpty) 'species': filterSpecies,
      if (filterGender != null && filterGender!.isNotEmpty) 'gender': filterGender,
      if (filterType != null && filterType!.isNotEmpty) 'type': filterType,
    };

    final queryString = filters.isNotEmpty
        ? filters.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value!)}').join('&')
        : '';

    final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character?page=$page${queryString.isNotEmpty ? '&$queryString' : ''}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load characters');
    }
  }

  void _applyFilters() async {
    currentPage = 1;
    final data = await _fetchCharacters(currentPage);
    setState(() {
      totalPages = data['info']['pages'] ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Characters'),
        backgroundColor: Colors.green.withOpacity(0.7),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wallpaper.png'),
                fit: BoxFit.cover, // Resmin tüm alanı kaplamasını sağlar
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Arka plana opaklık ekleyin
            ),
          ),
          Column(
            children: [
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fetchCharacters(currentPage),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || (snapshot.data!['results'] as List<dynamic>).isEmpty) {
                      return Center(
                        child: Text(
                          'No episodes found matching the filters.',
                          style: TextStyle(
                            color: Colors.white, // Metin rengini beyaz yapar
                            fontSize: 20.0, // Font boyutunu 18 olarak ayarlar
                          ),
                        ),
                      );
                    } else {
                      var characters = snapshot.data!['results'] as List<dynamic>;
                      totalPages = snapshot.data!['info']['pages'] ?? 1;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.9,
                          ),
                          itemCount: characters.length,
                          itemBuilder: (context, index) {
                            var character = characters[index];
                            return _buildCharacterCard(character, context);
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                color: Colors.white.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: currentPage > 1 ? () {
                        setState(() {
                          currentPage--;
                        });
                      } : null,
                    ),
                    DropdownButton<int>(
                      value: currentPage,
                      items: List.generate(totalPages, (index) => index + 1).map((page) {
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
                      icon: Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages ? () {
                        setState(() {
                          currentPage++;
                        });
                      } : null,
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
          backgroundColor: Colors.green.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Filter Characters',
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterName = value;
                  },
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterStatus = value;
                  },
                ),
                TextField(
                  controller: speciesController,
                  decoration: InputDecoration(
                    labelText: 'Species',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterSpecies = value;
                  },
                ),
                TextField(
                  controller: genderController,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterGender = value;
                  },
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterType = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Apply Filters',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                setState(() {
                  filterName = nameController.text.isEmpty ? null : nameController.text;
                  filterStatus = statusController.text.isEmpty ? null : statusController.text;
                  filterSpecies = speciesController.text.isEmpty ? null : speciesController.text;
                  filterGender = genderController.text.isEmpty ? null : genderController.text;
                  filterType = typeController.text.isEmpty ? null : typeController.text;
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

  Widget _buildCharacterCard(dynamic character, BuildContext context) {
    // Yardımcı fonksiyonlar
    String formatValue(String? value) {
      return (value?.toLowerCase() == 'unknown' || value == null) ? 'Unknown' : value;
    }

    MaterialColor _getStatusColor(String? status) {
      final formattedStatus = formatValue(status);
      return formattedStatus == 'Alive'
          ? Colors.green
          : formattedStatus == 'Dead'
          ? Colors.red
          : Colors.amber;
    }

    return GestureDetector(
      onTap: () {
        // Profil sayfasına yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterProfile(character: character), // CharacterProfile sayfasına karakteri gönderiyoruz
          ),
        );
      },
      child: Card(
        color: Colors.white.withOpacity(0.75),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            // Karakter resmi
            Container(
              width: 100, // Resmin genişliği
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: NetworkImage(character['image']), // Varsayılan resim
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Karakter bilgileri
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatValue(character['name']),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _getStatusColor(character['status']),
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formatValue(character['status']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold, // Kalın yazı tipi
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Wrap(
                      children: [
                        Text(
                          'Location: ',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          formatValue(character['location']?['name']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold, // Kalın yazı tipi
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'First seen in: ',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          (character['episode'] != null && character['episode'].isNotEmpty)
                              ? character['episode'][0].split('/').last
                              : 'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold, // Kalın yazı tipi
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}