import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, Map<String, String>> _backgroundSets = {
    "Set 1: FNAF 1": {
      "Animated": "assets/bg/fnaf1.gif",
      "Freddy(1)": "assets/bg/1.png",
      "Freddy Endo": "assets/bg/endo.png"
    },
    "Set 2: FNAF 2": {
      "Animated": "assets/bg/fnaf2.gif",
      "All Toys": "assets/bg/fnaf2toys.png",
      "All Toys With Wither Bonnie": "assets/bg/wb.png",
      "All Toys With Wither Chica": "assets/bg/wc.png"
    },
    "Set 3: FNAF 3": {
      "Animated": "assets/bg/fnaf3.gif",
      "SpringTrap": "assets/bg/sp1.png"
    },
    "Set 4: Default": {
      "Static Noise": "assets/bg/background.gif"
    }
  };

  late String _selectedSetName;
  String? _currentBackground;

  @override
  void initState() {
    super.initState();
    _selectedSetName = _backgroundSets.keys.first;
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBackground = prefs.getString('launcher_background') ?? "assets/bg/background.gif";
    });
  }

  Future<void> _setBackground(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('launcher_background', path);
    setState(() {
      _currentBackground = path;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Background updated to ${path.split('/').last}"),
        backgroundColor: const Color(0xFFB71C1C),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSet = _backgroundSets[_selectedSetName]!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            // Main Content Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Text(
                          "Settings",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          "Background Personalization",
                          style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFB71C1C), height: 1),

                  // Set Selection Dropdown
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Text("Select Background Set: ", style: TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(width: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFB71C1C)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSetName,
                              dropdownColor: Colors.grey[900],
                              style: const TextStyle(color: Colors.white),
                              items: _backgroundSets.keys.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() => _selectedSetName = newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Background Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 16 / 9,
                      ),
                      itemCount: currentSet.length,
                      itemBuilder: (context, index) {
                        final name = currentSet.keys.elementAt(index);
                        final path = currentSet.values.elementAt(index);
                        final isSelected = _currentBackground == path;

                        return GestureDetector(
                          onTap: () => _setBackground(path),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[800]!,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: const Color(0xFFB71C1C).withValues(alpha: 0.4), blurRadius: 8)]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Background Image Preview
                                  Image.asset(
                                    path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[900],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                  // Label Overlay
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      color: Colors.black.withValues(alpha: 0.6),
                                      child: Text(
                                        name,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  // Selection Indicator
                                  if (isSelected)
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(Icons.check_circle, color: Color(0xFFB71C1C), size: 24),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Sidebar
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                border: const Border(left: BorderSide(color: Color(0xFFB71C1C), width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _SidebarButton(
                    icon: Icons.close,
                    label: "Exit",
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        "FAZLAUNCHER",
                        style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
                      ),
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

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarButton({required this.icon, required this.label, required this.onTap});

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
