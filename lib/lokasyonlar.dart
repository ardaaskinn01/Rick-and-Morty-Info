import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationsPage extends StatefulWidget {
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
      if (filterDimension != null && filterDimension!.isNotEmpty) 'dimension': filterDimension,
    };

    final queryString = filters.isNotEmpty
        ? filters.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value!)}').join('&')
        : '';

    final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/location?page=$page${queryString.isNotEmpty ? '&$queryString' : ''}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load locations');
    }
  }

  void _applyFilters() async {
    // Filtreler uygulandığında, ilk sayfadan başla
    currentPage = 1;

    // Yeni verileri çek
    final data = await _fetchLocations(currentPage);

    // Toplam sayfa sayısını güncelle
    setState(() {
      totalPages = data['info']['pages'] ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locations'),
        backgroundColor: Colors.greenAccent.withOpacity(0.7),
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
                  future: _fetchLocations(currentPage),
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
                      var locations = snapshot.data!['results'] as List<dynamic>;
                      totalPages = snapshot.data!['info']['pages'] ?? 7;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.9,
                          ),
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            var location = locations[index];
                            return _buildLocationCard(location);
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
          backgroundColor: Colors.greenAccent.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Filter Locations',
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
                TextField(
                  controller: dimensionController,
                  decoration: InputDecoration(
                    labelText: 'Dimension',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    filterDimension = value;
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
                  filterType = typeController.text.isEmpty ? null : typeController.text;
                  filterDimension = dimensionController.text.isEmpty ? null : dimensionController.text;
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

  Widget _buildLocationCard(dynamic location) {
    return Card(
      color: Colors.white.withOpacity(0.75),
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
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: 'Type: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: location['type'] != null && location['type'] != 'unknown'
                        ? location['type']
                        : 'Unknown',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 7),
            RichText(
              text: TextSpan(
                text: 'Dimension: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: location['dimension'] != null && location['dimension'] != 'unknown'
                        ? location['dimension']
                        : 'Unknown',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 7),
            RichText(
              text: TextSpan(
                text: 'Residents: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: '${location['residents'] != null ? location['residents'].length : 0} residents',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
