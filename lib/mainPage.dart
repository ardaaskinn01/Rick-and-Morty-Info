import 'package:flutter/material.dart';
import 'characters.dart';
import 'episodes.dart';
import 'locations.dart';

class Anasayfa extends StatelessWidget {
  const Anasayfa({super.key});

  // Arayüz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              color: Colors.lightGreen.withOpacity(0.15),
            ),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              _buildImageButton(
                context,
                'Characters',
                'assets/images/characters.png',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CharactersPage()), // Karakterler ekranına geçiş
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildImageButton(
                context,
                'Locations',
                'assets/images/locations.png',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LocationsPage()), // Lokasyonlar ekranına geçiş
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildImageButton(
                context,
                'Episodes',
                'assets/images/episodes.png',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EpisodesPage()), // Bölümler ekranına geçiş
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Ekranlara Geçiş Butonlarının Tasarımı
  Widget _buildImageButton(BuildContext context, String title, String imagePath,
      VoidCallback onPressed) {
    double buttonHeight =
        MediaQuery.of(context).size.height * 0.2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.5),
          ),
          onPressed: onPressed,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 6.0,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.black.withOpacity(0.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
