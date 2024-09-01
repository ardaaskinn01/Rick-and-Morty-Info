import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rick_and_morty_mobile/characterProfile.dart';

class LocationProfile extends StatefulWidget {
  final Map<String, dynamic> location;

  const LocationProfile({super.key, required this.location});

  @override
  _LocationProfileState createState() => _LocationProfileState();
}

class _LocationProfileState extends State<LocationProfile> {
  Map<String, dynamic>? _locationDetails;
  List<Map<String, dynamic>> _residents = [];
  bool _isResidentsVisible = false;

  @override
  void initState() {
    super.initState();
    _locationDetails = widget.location;
    _fetchLocationDetails();
  }

  Future<void> _fetchLocationDetails() async {
    final locationUrl = widget.location['url'] as String?;
    if (locationUrl != null && locationUrl.isNotEmpty) {
      final response = await http.get(Uri.parse(locationUrl));
      if (response.statusCode == 200) {
        final locationData = jsonDecode(response.body);
        setState(() {
          _locationDetails = locationData;
        });
      }
    }
  }

  Future<void> _fetchResidentNames() async {
    final List<String> residentUrls =
        List<String>.from(_locationDetails?['residents'] ?? []);
    final List<Map<String, dynamic>> residents = [];

    final List<Future<http.Response>> requests =
        residentUrls.map((url) => http.get(Uri.parse(url))).toList();
    final List<http.Response> responses = await Future.wait(requests);

    for (var response in responses) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        residents.add(data);
      } else {}
    }
    setState(() {
      _residents = residents;
    });
  }

  void _toggleResidentsVisibility() {
    if (_isResidentsVisible) {
      setState(() {
        _residents = [];
        _isResidentsVisible = false;
      });
    } else {
      _fetchResidentNames().then((_) {
        setState(() {
          _isResidentsVisible = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          formatValue(widget.location['name']),
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
                  if (_locationDetails != null)
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
                        formatValue(widget.location['name']),
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
                  if (_locationDetails != null)
                    _buildLocationDetail(
                        'Type', formatValue(_locationDetails!['type'])),
                  if (_locationDetails != null)
                    _buildLocationDetail('Dimension',
                        formatValue(_locationDetails!['dimension'])),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleResidentsVisibility,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      _isResidentsVisible
                          ? 'Hide Residents'
                          : 'See the Residents',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isResidentsVisible && _residents.isNotEmpty)
                    Container(
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
                            'Residents:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ..._residents.map((resident) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CharacterProfile(
                                            character: resident),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Text(
                                      resident['name'],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            );
                          }),
                        ],
                      ),
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

  Widget _buildLocationDetail(String title, String value) {
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
}
