import 'package:flutter/material.dart';
import 'karakterler.dart'; // Yeni sayfaları içe aktar
import 'bölümler.dart';
import 'lokasyonlar.dart';

class Anasayfa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan resmi
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wallpaper.png'),
                fit: BoxFit.cover, // Resmin tüm alanı kaplamasını sağlar
              ),
            ),
            child: Container(
              color: Colors.lightGreen.withOpacity(0.15), // Arka plana opaklık ekleyin
            ),
          ),
          // İçerik
          Padding(
            padding: const EdgeInsets.all(1.0), // Ekranın etrafına boşluk ekliyoruz
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3), // Ekranın üst kısmında boşluk bırakır
                _buildImageButton(
                  context,
                  'Characters',
                  'assets/images/characters.png',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CharactersPage()),
                    );
                  },
                ),
                SizedBox(height: 20), // Butonlar arasında boşluk
                _buildImageButton(
                  context,
                  'Locations',
                  'assets/images/locations.png',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocationsPage()),
                    );
                  },
                ),
                SizedBox(height: 20), // Butonlar arasında boşluk
                _buildImageButton(
                  context,
                  'Episodes',
                  'assets/images/episodes.png',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EpisodesPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(BuildContext context, String title, String imagePath, VoidCallback onPressed) {
    // Ekranın yüksekliğini ve buton yüksekliğini yüzdelik olarak hesapla
    double buttonHeight = MediaQuery.of(context).size.height * 0.2; // Ekranın yüksekliğinin %20'si

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Butonlar arasında yatay boşluk bırakıyoruz
      child: SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            // Butona gölge ekliyoruz
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.5),
          ),
          onPressed: onPressed,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // Görsele kenarlık (border) ekliyoruz
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, // Görseli butonun boyutuna göre kapla
                ),
              ),
              Container(
                // Kenarlık (border) eklemek için BoxDecoration kullanıyoruz
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white, // Kenarlığın rengi
                    width: 6.0, // Kenarlığın kalınlığı
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.black.withOpacity(0.5), // Arka plan rengi (opacitesi ile)
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
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