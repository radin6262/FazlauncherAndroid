import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:installed_apps/installed_apps.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gallery.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const FNAFLauncherApp());
}

class Game {
  final String id;
  final String name;
  final String package;
  final String androidUrl;
  final String windowsUrl;
  final String icon;
  final String image;

  Game({
    required this.id,
    required this.name,
    required this.package,
    required this.androidUrl,
    required this.windowsUrl,
    required this.icon,
    required this.image,
  });
}

final List<Game> GAMES = [
  Game(
    id: "fnaf1",
    name: "Five Nights at Freddy's",
    package: "com.scottgames.fivenightsatfreddys",
    androidUrl: "https://www.dl.farsroid.com/game/Five-Night-at-Freddys-2.0.7(www.Farsroid.com).apk",
    windowsUrl: "https://abrehamrahi.ir/o/public/sZhIO0o1/",
    icon: "F️",
    image: "assets/images/fnaf1.png",
  ),
  Game(
    id: "fnaf2",
    name: "Five Nights at Freddy's 2",
    package: "com.scottgames.fnaf2",
    androidUrl: "https://www.dl.farsroid.com/game/Five-Nights-at-Freddys-2-2.0.7(www.Farsroid.com).apk",
    windowsUrl: "https://example.com/fnaf2.zip",
    icon: "F",
    image: "assets/images/fnaf2.png",
  ),
  Game(
    id: "fnaf3",
    name: "Five Nights at Freddy's 3",
    package: "com.scottgames.fnaf3",
    androidUrl: "https://www.dl.farsroid.com/game/Five-Nights-at-Freddys-3-2.0.4(www.Farsroid.com).apk",
    windowsUrl: "https://example.com/fnaf3.zip",
    icon: "F",
    image: "assets/images/fnaf3.png",
  ),
  Game(
    id: "fnaf4",
    name: "Five Nights at Freddy's 4",
    package: "com.scottgames.fnaf4",
    androidUrl: "https://www.dl.farsroid.com/game/Five-Nights-at-Freddys-4-2.0.4(www.Farsroid.com).apk",
    windowsUrl: "https://example.com/fnaf4.zip",
    icon: "F",
    image: "assets/images/fnaf4.png",
  ),
];

class FNAFLauncherApp extends StatelessWidget {
  const FNAFLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FNAF Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red[900],
        scaffoldBackgroundColor: Colors.black,
        dividerColor: Colors.red[900],
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB71C1C),
          secondary: Colors.grey,
        ),
      ),
      home: const LauncherHome(),
    );
  }
}

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() => _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome> {
  int _selectedIndex = 0;
  String _statusText = "Ready";
  Color _statusColor = Colors.grey;
  double _progress = 0;
  bool _isDownloading = false;
  late Directory _downloadDir;
  bool _debugMode = false;
  String _backgroundSrc = "assets/bg/background.gif";
  final Map<String, String> _gameFileStatus = {};
  final Map<String, bool> _gameInstalledStatus = {};
  final Map<String, String> _gameStorageInfo = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _initStorage();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _debugMode = prefs.getBool('debugging_mode') ?? false;
      _backgroundSrc = prefs.getString('launcher_background') ?? "assets/bg/background.gif";
    });
  }

  Future<void> _initStorage() async {
    final appDir = await getApplicationDocumentsDirectory();
    _downloadDir = Directory(p.join(appDir.path, 'FNAF_Launcher'));
    if (!await _downloadDir.exists()) {
      await _downloadDir.create(recursive: true);
    }
    _refreshAllStatus();
  }

  Future<void> _refreshAllStatus() async {
    for (var game in GAMES) {
      final filePath = p.join(_downloadDir.path, Platform.isAndroid ? "${game.id}.apk" : "${game.id}.zip");
      final file = File(filePath);

      bool isInstalled = false;
      if (Platform.isAndroid) {
        isInstalled = await InstalledApps.isAppInstalled(game.package) ?? false;
      }

      String fileStatus = "Not downloaded";
      if (isInstalled) {
        fileStatus = "Installed";
      } else if (file.existsSync()) {
        fileStatus = "Downloaded";
      }

      String storageText = "None";
      if (file.existsSync()) {
        final size = file.lengthSync();
        storageText = "${(size / (1024 * 1024)).toStringAsFixed(1)} MB";
      }

      setState(() {
        _gameFileStatus[game.id] = fileStatus;
        _gameInstalledStatus[game.id] = isInstalled;
        _gameStorageInfo[game.id] = storageText;
      });
    }
  }

  Future<void> _handleInstallOrPlay(Game game) async {
    if (Platform.isAndroid) {
      bool isInstalled = await InstalledApps.isAppInstalled(game.package) ?? false;
      if (isInstalled) {
        setState(() {
          _statusText = "Launching ${game.name}...";
          _statusColor = Colors.green;
        });
        await InstalledApps.startApp(game.package);
        if (!_debugMode) {
          setState(() => _statusText = "Game Launched!");
        }
        return;
      }
    }

    final filePath = p.join(_downloadDir.path, Platform.isAndroid ? "${game.id}.apk" : "${game.id}.zip");
    final file = File(filePath);

    if (file.existsSync()) {
      setState(() {
        _statusText = Platform.isAndroid ? "Installing ${game.name}..." : "Launching ${game.name}...";
        _statusColor = Colors.orange;
      });
      await OpenFilex.open(filePath);
      return;
    }

    _startDownload(game, filePath);
  }

  Future<void> _startDownload(Game game, String filePath) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _statusText = "Starting download...";
      _statusColor = Colors.orange;
      _progress = 0;
    });

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(Platform.isAndroid ? game.androidUrl : game.windowsUrl));
      final response = await client.send(request);

      final total = response.contentLength ?? 0;
      var received = 0;

      final file = File(filePath);
      final sink = file.openWrite();

      await response.stream.listen((chunk) {
        received += chunk.length;
        sink.add(chunk);
        if (total != 0) {
          setState(() {
            _progress = received / total;
            _statusText = "Downloading: ${(received / (1024 * 1024)).toStringAsFixed(1)} MB / ${(total / (1024 * 1024)).toStringAsFixed(1)} MB (${(_progress * 100).toStringAsFixed(1)}%)";
          });
        }
      }).asFuture();

      await sink.close();
      client.close();

      setState(() {
        _isDownloading = false;
        _statusText = "Download complete!";
        _statusColor = Colors.green;
      });
      await _refreshAllStatus();
      _handleInstallOrPlay(game);
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusText = "Download failed: $e";
        _statusColor = Colors.red;
      });
    }
  }

  Future<void> _clearCache(Game game) async {
    final filePath = p.join(_downloadDir.path, Platform.isAndroid ? "${game.id}.apk" : "${game.id}.zip");
    final file = File(filePath);

    if (file.existsSync()) {
      await file.delete();
      setState(() {
        _statusText = "Files cleared for ${game.name}";
        _statusColor = Colors.orange;
      });
      await _refreshAllStatus();
    } else {
      setState(() {
        _statusText = "Nothing to clear";
        _statusColor = Colors.grey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              _backgroundSrc,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),
          
          SafeArea(
            child: Row(
              children: [
                // Left Side: Title and Game Cards
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/launcher-title.png",
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.gamepad, size: 48, color: Colors.red),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "FazLauncher",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              "v1.0 - ARR 2026",
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                            const Spacer(),
                            if (_isDownloading)
                               Container(
                                 width: 150,
                                 padding: const EdgeInsets.only(right: 10),
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(5),
                                   child: LinearProgressIndicator(
                                     value: _progress,
                                     minHeight: 8,
                                     color: const Color(0xFFB71C1C),
                                     backgroundColor: Colors.grey[900],
                                   ),
                                 ),
                               ),
                            Text(
                              _statusText,
                              style: TextStyle(color: _statusColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(height: 1, thickness: 1, color: Color(0xFFB71C1C)),

                      // Horizontal Game Cards
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          itemCount: GAMES.length,
                          itemBuilder: (context, index) {
                            final game = GAMES[index];
                            final isSelected = _selectedIndex == index;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 230, // Keeps 3:4 ratio while increasing height
                                  height: 700, // Significant height increase
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFB71C1C) : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: isSelected ? [
                                      BoxShadow(color: const Color(0xFFB71C1C).withValues(alpha: 0.5), blurRadius: 10)
                                    ] : [],
                                  ),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                    color: Colors.transparent,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Full Game Image
                                        Image.asset(
                                          game.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                            Container(color: Colors.grey[900], child: const Icon(Icons.image, size: 50)),
                                        ),
                                        
                                        // Status Icon Overlay (Top Left)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Icon(
                                            Icons.download_for_offline,
                                            size: 24,
                                            color: _getStatusColor(game.id),
                                          ),
                                        ),

                                        // Action Buttons (Overlayed at Bottom Right)
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Play Button
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                                  onPressed: () => _handleInstallOrPlay(game),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Delete Button
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 18),
                                                  onPressed: () => _clearCache(game),
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                      _SidebarButton(
                        icon: Icons.photo_library,
                        label: "Gallery",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryPage())),
                      ),
                      const SizedBox(height: 20),
                      _SidebarButton(
                        icon: Icons.settings,
                        label: "Settings",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())).then((_) => _loadConfig()),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.white70),
                        onPressed: () {
                          _scrollController.animateTo(
                            _scrollController.offset - 200,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward, color: Colors.white70),
                        onPressed: () {
                          _scrollController.animateTo(
                            _scrollController.offset + 200,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String gameId) {
    final status = _gameFileStatus[gameId];
    if (status == "Installed") return Colors.green;
    if (status == "Downloaded") return Colors.orange;
    return Colors.red;
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
