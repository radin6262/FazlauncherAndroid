import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final Map<String, List<String>> _imageSets = {
    "FNAF 1": [
      "assets/gallery/BareEndoClean.png",
      "assets/gallery/Freddy_Fazbear (3).png",
      "assets/gallery/Bonnie_Rabbit (1).png",
      "assets/gallery/Chica (1).png",
      "assets/gallery/foxy.png",
      "assets/gallery/goldenfreddy.png",
    ],
    "FNAF 2": [
      "assets/gallery/fnaf2endo.png",
      "assets/gallery/Toy_freddy.png",
      "assets/gallery/Toy_bonnie.png",
      "assets/gallery/Toy_Chica_OfficialRender.png",
      "assets/gallery/Mangle.png",
      "assets/gallery/FNAF2BB.png",
      "assets/gallery/JJ_UCN.png",
      "assets/gallery/Withered_Chica (1).png",
      "assets/gallery/Withered_foxy.png",
      "assets/gallery/WitheredBonnie_Office.png",
      "assets/gallery/OldFreddyTransparent.png",
      "assets/gallery/FNAF2SlumpedGoldenFreddy (1).png",
    ],
    "FNAF 3": [
      "assets/gallery/Extra_Springtrap_1 (1).png",
      "assets/gallery/FNAF3ShadowFreddy.png",
      "assets/gallery/Phantom_Fred_UCN.png",
      "assets/gallery/PhantomFoxyOffice.png",
      "assets/gallery/PhantomMangle_Infobox.png",
      "assets/gallery/Extra_BB.png",
      "assets/gallery/Extra_Chica.png",
      "assets/gallery/Extra_Puppet.png",
    ],
    "FNAF 4": [
      "assets/gallery/Nightmare_Bonnie.png",
      "assets/gallery/Nightmare_Chica.png",
      "assets/gallery/Nightmare_Foxy.png",
      "assets/gallery/Nightmare_Freddy.png",
      "assets/gallery/NightmareBB.png",
      "assets/gallery/NightmareMangle.png",
      "assets/gallery/Nightmareextra (1).png",
      "assets/gallery/Nightmarefredbearextra.png",
      "assets/gallery/FNaF4_-_Extra_%28Nightmarionne%29.png",
      "assets/gallery/Plushtrap_UCN.png",
    ],
    "Halloween": [
      "assets/gallery/BonnieJACK-O.png",
      "assets/gallery/Jack-O-Chica.png",
    ],
    "Shadows": [
      "assets/gallery/ShadowFreddy.png",
      "assets/gallery/ShadowBonnie_UCN.png",
    ],
  };

  late String _selectedSet;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedSet = _imageSets.keys.first;
  }

  void _navigateLeft() {
    setState(() {
      final images = _imageSets[_selectedSet]!;
      _currentIndex = (_currentIndex - 1 + images.length) % images.length;
    });
  }

  void _navigateRight() {
    setState(() {
      final images = _imageSets[_selectedSet]!;
      _currentIndex = (_currentIndex + 1) % images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = _imageSets[_selectedSet]!;
    final currentImage = images[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            // Left Side: Selection Area
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: const Border(right: BorderSide(color: Color(0xFFB71C1C), width: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Select Set",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Color(0xFFB71C1C), thickness: 1),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: _imageSets.keys.map((String value) {
                          final isSelected = _selectedSet == value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedSet = value;
                                  _currentIndex = 0;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFB71C1C).withValues(alpha: 0.2) : Colors.black45,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[900]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey,
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center: Image Display Area
            Expanded(
              flex: 2, // Card now takes twice the space of the selection area
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      _selectedSet,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  // Main Image Card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900]?.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFB71C1C), size: 36),
                              onPressed: _navigateLeft,
                            ),
                            Expanded(
                              child: InteractiveViewer(
                                child: Image.asset(
                                  currentImage,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                      const SizedBox(height: 10),
                                      Text("Not Found:\n${currentImage.split('/').last}", 
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFB71C1C), size: 36),
                              onPressed: _navigateRight,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Side: Sidebar
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                border: const Border(left: BorderSide(color: Color(0xFFB71C1C), width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _SidebarActionButton(
                    icon: Icons.close,
                    label: "Exit",
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Indicators of current image count
                  Text(
                    "${_currentIndex + 1}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    "/ ${images.length}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
