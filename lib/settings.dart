import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// ============================================================
// Global launcher music controller
// ============================================================

class _LauncherMusic {
  static final AudioPlayer player = AudioPlayer();

  // NOTE: AssetSource automatically adds 'assets/' to the start of this string.
  // This expects your file to be exactly at: [Project Folder]/assets/audio/launcher.mp3
  static const String musicAsset = 'audio/launcher.mp3';

  static bool _configured = false;

  static Future<void> _configure() async {
    if (_configured) return;

    // 1. Add listeners to catch exact errors (like missing files) in the console
    player.onLog.listen((String message) {
      debugPrint("AudioPlayer Log: $message");
    });

    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(1.0);
      _configured = true;
    } catch (e) {
      debugPrint("AudioPlayer configuration failed: $e");
    }
  }

  static Future<void> play() async {
    try {
      await _configure();

      // Play the asset using AssetSource
      await player.play(AssetSource(musicAsset));
    } catch (e) {
      debugPrint("AudioPlayer play failed: $e");
    }
  }

  static Future<void> stop() async {
    try {
      await player.stop();
    } catch (e) {
      debugPrint("AudioPlayer stop failed: $e");
    }
  }

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
    "Set 4: FNAF 4": {
      "FNAF 4 Background": "assets/bg/fnaf4bg2.png",
      "Nightmare Bonnie": "assets/bg/nightmarebonnie4.png",
      "Nightmare Chica": "assets/bg/nightmarechica4.png",
      "Nightmare Foxy": "assets/bg/nightmarefoxy4.png",
      "Nightmare Freddy": "assets/bg/nightmarefreddy4.png"
    },
    "Set 5: FNAF SL": {
      "Ballora Animated": "assets/bg/ballora.gif",
      "Circus Baby Animated": "assets/bg/circusbaby.gif",
      "Funtime Foxy Animated": "assets/bg/funtimefoxy.gif",
      "Funtime Freddy Animated": "assets/bg/funtimefreddy.gif",
      "Circus Baby": "assets/bg/circusbaby.png",
    },
    "Set 6: FNAF 6": {
      "Rockstars": "assets/bg/fnaf6.png",
      "Fazbear Entertainment": "assets/bg/FazBearEnterTainment.png",
      "Fazbear Shed": "assets/bg/fazbearshed.png",
    },
    "Set 7: Default": {
      "Static Noise": "assets/bg/background.gif"
    }
  };

  late String _selectedSetName;
  String? _currentBackground;

  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();

    _selectedSetName = _backgroundSets.keys.first;

    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final musicEnabled =
        prefs.getBool('launcher_music_enabled') ?? true;

    setState(() {
      _currentBackground =
          prefs.getString('launcher_background') ??
              "assets/bg/background.gif";

      _musicEnabled = musicEnabled;
    });

    // Start music automatically when the saved setting is ON.
    if (musicEnabled) {
      try {
        await _LauncherMusic.play();
      } catch (e) {
        debugPrint("Music playback failed: $e");
      }
    }
  }

  Future<void> _toggleMusic() async {
    final newValue = !_musicEnabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'launcher_music_enabled',
      newValue,
    );

    if (!mounted) return;

    setState(() {
      _musicEnabled = newValue;
    });

    try {
      if (newValue) {
        await _LauncherMusic.play();
      } else {
        await _LauncherMusic.stop();
      }
    } catch (e) {
      debugPrint("Music toggle failed: $e");
    }
  }

  Future<void> _setBackground(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('launcher_background', path);

    if (!mounted) return;

    setState(() {
      _currentBackground = path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Background updated to ${path.split('/').last}",
        ),
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
            // ============================================================
            // MAIN CONTENT
            // ============================================================
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HEADER
                      // ==================================================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          10,
                          120,
                          0,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "Settings",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // BACKGROUND SET SELECTOR
                      // ==================================================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          22,
                          14,
                          7,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Background Set:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFB71C1C),
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSetName,
                                  dropdownColor: Colors.grey[900],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  isDense: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  items: _backgroundSets.keys.map(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedSetName = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // BACKGROUND GRID
                      // ==================================================
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            14,
                            0,
                            14,
                            10,
                          ),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 16 / 9,
                          ),
                          itemCount: currentSet.length,
                          itemBuilder: (context, index) {
                            final name =
                            currentSet.keys.elementAt(index);
                            final path =
                            currentSet.values.elementAt(index);
                            final isSelected =
                                _currentBackground == path;

                            return GestureDetector(
                              onTap: () => _setBackground(path),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 120),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(7),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFB71C1C)
                                        : Colors.grey[800]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFB71C1C,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 5,
                                    ),
                                  ]
                                      : [],
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(6),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        path,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[900],
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),

                                      // Label
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 4,
                                          ),
                                          color: Colors.black.withValues(
                                            alpha: 0.65,
                                          ),
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),

                                      // Selection Indicator
                                      if (isSelected)
                                        const Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Color(0xFFB71C1C),
                                            size: 18,
                                          ),
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

                  // ========================================================
                  // HELPY
                  // ========================================================
                  Positioned(
                    top: 2,
                    right: 6,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        "assets/images/helpy.png",
                        fit: BoxFit.contain,
                        alignment: Alignment.topRight,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 36,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // SIDEBAR
            // ============================================================
            Container(
              width: 54,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFFB71C1C),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ======================================================
                  // MUSIC BUTTON
                  // ======================================================
                  _SidebarButton(
                    icon: Icons.music_note,
                    label: "Music",
                    enabled: _musicEnabled,
                    onTap: _toggleMusic,
                  ),

                  const SizedBox(height: 10),

                  // ======================================================
                  // EXIT BUTTON
                  // ======================================================
                  _SidebarButton(
                    icon: Icons.close,
                    label: "Exit",
                    onTap: () => Navigator.pop(context),
                  ),

                  const Spacer(),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        "FAZLAUNCHER",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 8,
                          letterSpacing: 2,
                        ),
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
  final bool enabled;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: enabled
                  ? const Color(0xFFB71C1C)
                  : Colors.grey,
              size: 23,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: enabled
                    ? Colors.white
                    : Colors.white54,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}