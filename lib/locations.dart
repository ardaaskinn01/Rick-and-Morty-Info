import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rick_and_morty_mobile/locationProfile.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  int currentPage = 1;
  int totalPages = 7;
  String? filterName;
  String? filterType;
  String? filterDimension;

  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController dimensionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: filterName);
    typeController = TextEditingController(text: filterType);
    dimensionController = TextEditingController(text: filterDimension);
  }

  Future<Map<String, dynamic>> _fetchLocations(int page) async {
    final filters = {
      if (filterName != null && filterName!.isNotEmpty) 'name': filterName,
      if (filterType != null && filterType!.isNotEmpty) 'type': filterType,
      if (filterDimension != null && filterDimension!.isNotEmpty)
        'dimension': filterDimension,
    };

    final queryString = filters.isNotEmpty
        ? filters.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value!)}')
            .join('&')
        : '';

    final response = await http.get(Uri.parse(
        'https://rickandmortyapi.com/api/location?page=$page${queryString.isNotEmpty ? '&$queryString' : ''}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load locations');
    }
  }

  void _applyFilters() async {
    currentPage = 1;

    final data = await _fetchLocations(currentPage);

    setState(() {
      totalPages = data['info']['pages'] ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Locations',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.lightGreen.withOpacity(0.85),
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
                  future: _fetchLocations(currentPage),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData ||
                        (snapshot.data!['results'] as List<dynamic>).isEmpty) {
                      return const Center(
                        child: Text(
                          'No locations found matching the filters.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      );
                    } else {
                      var locations =
                          snapshot.data!['results'] as List<dynamic>;
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
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            var location = locations[index];
                            return _buildLocationCard(location, context);
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                color: Colors.lightGreen.withOpacity(0.8),
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
                      icon: const Icon(Icons.arrow_forward_ios),
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
          backgroundColor: Colors.lightGreen.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'Filter Locations',
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
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterType = value;
                  },
                ),
                TextField(
                  controller: dimensionController,
                  decoration: const InputDecoration(
                    labelText: 'Dimension',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterDimension = value;
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
                  filterType =
                      typeController.text.isEmpty ? null : typeController.text;
                  filterDimension = dimensionController.text.isEmpty
                      ? null
                      : dimensionController.text;
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

  Widget _buildLocationCard(dynamic location, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationProfile(location: location),
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
                location['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFD6368),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Type: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: location['type'] != null &&
                              location['type'] != 'unknown'
                          ? location['type']
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
              const SizedBox(height: 7),
              RichText(
                text: TextSpan(
                  text: 'Dimension: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: location['dimension'] != null &&
                              location['dimension'] != 'unknown'
                          ? location['dimension']
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
              const SizedBox(height: 7),
              RichText(
                text: TextSpan(
                  text: 'Residents: ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${location['residents'] != null ? location['residents'].length : 0} residents',
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
