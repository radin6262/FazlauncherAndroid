import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:installed_apps/installed_apps.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

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

// ============================================================
// Launcher Music Controller
// ============================================================

class LauncherMusic {
  static final AudioPlayer player = AudioPlayer();

  static const String musicAsset = 'audio/launcher.mp3';
  static const String preferenceKey =
      'launcher_music_enabled';

  static bool _configured = false;

  static Future<void> _configure() async {
    if (_configured) return;

    await player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          audioMode: AndroidAudioMode.normal,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
          isSpeakerphoneOn: true,
          stayAwake: false,
        ),
      ),
    );

    await player.setPlayerMode(
      PlayerMode.mediaPlayer,
    );

    await player.setReleaseMode(
      ReleaseMode.loop,
    );

    await player.setVolume(1.0);

    _configured = true;
  }

  static Future<void> play() async {
    await _configure();

    // Don't restart the track if it is already playing.
    final state = player.state;

    if (state == PlayerState.playing) {
      return;
    }

    debugPrint(
      'LAUNCHER MUSIC: starting "$musicAsset"',
    );

    await player.play(
      AssetSource(musicAsset),
    );

    debugPrint(
      'LAUNCHER MUSIC: playback started',
    );
  }

  static Future<void> stop() async {
    debugPrint(
      'LAUNCHER MUSIC: stopping',
    );

    await player.stop();
  }

  static Future<void> syncWithPreference() async {
    final prefs =
    await SharedPreferences.getInstance();

    final enabled =
        prefs.getBool(preferenceKey) ?? true;

    debugPrint(
      'LAUNCHER MUSIC: saved setting = $enabled',
    );

    if (enabled) {
      await play();
    } else {
      await stop();
    }
  }

  static Future<void> dispose() async {
    await player.dispose();
    _configured = false;
  }
}

// ============================================================
// Game
// ============================================================

class Game {
  final String id;
  final String name;
  final String package;
  final String androidUrl;
  final String windowsUrl;
  final String icon;

  // Image used ONLY for the game card.
  final String image;

  // Image used ONLY for the full-screen 4-second
  // launch splash.
  final String launchImage;

  Game({
    required this.id,
    required this.name,
    required this.package,
    required this.androidUrl,
    required this.windowsUrl,
    required this.icon,
    required this.image,
    required this.launchImage,
  });
}

// ============================================================
// Games
// ============================================================

final List<Game> games = [
  Game(
    id: "fnaf1",
    name: "Five Nights at Freddy's",
    package:
    "com.scottgames.fivenightsatfreddys",
    androidUrl:
    "https://www.dl.farsroid.com/game/Five-Night-at-Freddys-2.0.7(www.Farsroid.com).apk",
    windowsUrl:
    "https://abrehamrahi.ir/o/public/sZhIO0o1/",
    icon: "F",
    image: "assets/images/fnaf1.png",
    launchImage: "assets/splash/fnaf1.png",
  ),
  Game(
    id: "fnaf2",
    name: "Five Nights at Freddy's 2",
    package:
    "com.scottgames.fnaf2",
    androidUrl:
    "https://www.dl.farsroid.com/game/Five-Nights-at-Freddys-2-2.0.7(www.Farsroid.com).apk",
    windowsUrl:
    "https://example.com/fnaf2.zip",
    icon: "F",
    image: "assets/images/fnaf2.png",
    launchImage: "assets/splash/fnaf2.png",
  ),
  Game(
    id: "fnaf3",
    name: "Five Nights at Freddy's 3",
    package:
    "com.scottgames.fnaf3",
    androidUrl:
    "https://www.dl.farsroid.com/game/Five-Nights-at-Freddys-3-2.0.4(www.Farsroid.com).apk",
    windowsUrl:
    "https://example.com/fnaf3.zip",
    icon: "F",
    image: "assets/images/fnaf3.png",
    launchImage: "assets/splash/fnaf3.png",
  ),
  Game(
    id: "fnaf4",
    name: "Five Nights at Freddy's 4",
    package:
    "com.scottgames.fnaf4",
    androidUrl:
    "https://www.dl.farsroid.com/game/Five-Nights-at-Freddys-4-2.0.4(www.Farsroid.com).apk",
    windowsUrl:
    "https://example.com/fnaf4.zip",
    icon: "F",
    image: "assets/images/fnaf4.png",
    launchImage: "assets/splash/fnaf4.png",
  ),
  Game(
    id: "fnaf5",
    name:
    "Five Nights at Freddy's: Sister Location",
    package:
    "com.scottgames.sisterlocation",
    androidUrl:
    "https://www.dl.farsroid.com/game/Five-Nights-at-Freddys-Sister-Location-2.0.5(Farsroid.com).apk",
    windowsUrl:
    "https://example.com/fnaf5.zip",
    icon: "F",
    image: "assets/images/slcard.png",
    launchImage: "assets/splash/fnaf5.png",
  ),
  Game(
    id: "fnaf6",
    name:
    "Five Nights at Freddy's 6",
    package:
    "com.clickteam.freddyfazbearspizzeriasimulator",
    androidUrl:
    "https://www.dl.farsroid.com/game/FNaF-6-Pizzeria-Simulator-1.0.8(www.Farsroid.com).apk",
    windowsUrl:
    "https://example.com/fnaf6.zip",
    icon: "F",
    image:
    "assets/images/fnaf6card.png",
    launchImage:
    "assets/splash/fnaf6.png",
  ),
];

// ============================================================
// App
// ============================================================

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

// ============================================================
// Launcher Home
// ============================================================

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() =>
      _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  String _statusText = "Ready";
  Color _statusColor = Colors.grey;

  double _progress = 0;
  bool _isDownloading = false;

  late Directory _downloadDir;

  bool _debugMode = false;

  String _backgroundSrc =
      "assets/bg/background.gif";

  final Map<String, String> _gameFileStatus = {};
  final Map<String, bool> _gameInstalledStatus = {};
  final Map<String, String> _gameStorageInfo = {};

  final ScrollController _scrollController =
  ScrollController();

  // ============================================================
  // Launch Splash
  // ============================================================

  late final AnimationController
  _launchSplashController;

  static const Duration _launchSplashDuration =
  Duration(seconds: 4);

  bool _showLaunchSplash = false;

  Game? _launchSplashGame;

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _launchSplashController =
        AnimationController(
          vsync: this,
          duration: _launchSplashDuration,
        );

    _loadConfig();
    _initStorage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    _launchSplashController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // App Lifecycle
  // ============================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _syncMusic();
      _loadConfig();
    }
  }

  // ============================================================
  // Config
  // ============================================================

  Future<void> _loadConfig() async {
    final prefs =
    await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _debugMode =
          prefs.getBool('debugging_mode') ?? false;

      _backgroundSrc =
          prefs.getString(
            'launcher_background',
          ) ??
              "assets/bg/background.gif";
    });

    await _syncMusic();
  }

  Future<void> _syncMusic() async {
    try {
      await LauncherMusic.syncWithPreference();
    } catch (e) {
      debugPrint(
        'LAUNCHER MUSIC SYNC ERROR: $e',
      );
    }
  }

  // ============================================================
  // Storage
  // ============================================================

  Future<void> _initStorage() async {
    final appDir =
    await getApplicationDocumentsDirectory();

    _downloadDir = Directory(
      p.join(
        appDir.path,
        'FNAF_Launcher',
      ),
    );

    if (!await _downloadDir.exists()) {
      await _downloadDir.create(
        recursive: true,
      );
    }

    await _refreshAllStatus();
  }

  Future<void> _refreshAllStatus() async {
    for (final game in games) {
      final filePath = p.join(
        _downloadDir.path,
        Platform.isAndroid
            ? "${game.id}.apk"
            : "${game.id}.zip",
      );

      final file = File(filePath);

      bool isInstalled = false;

      if (Platform.isAndroid) {
        isInstalled =
            await InstalledApps.isAppInstalled(
              game.package,
            ) ??
                false;
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

        storageText =
        "${(size / (1024 * 1024)).toStringAsFixed(1)} MB";
      }

      if (!mounted) return;

      setState(() {
        _gameFileStatus[game.id] =
            fileStatus;

        _gameInstalledStatus[game.id] =
            isInstalled;

        _gameStorageInfo[game.id] =
            storageText;
      });
    }
  }

  // ============================================================
  // Launch Splash
  // ============================================================

  Future<void> _showGameLaunchSplash(
      Game game,
      Future<void> Function() action,
      ) async {
    if (!mounted) return;

    if (_showLaunchSplash) {
      return;
    }

    debugPrint(
      'LAUNCHER SPLASH: '
          '${game.name} -> ${game.launchImage}',
    );

    setState(() {
      _showLaunchSplash = true;
      _launchSplashGame = game;

      _statusText =
      "Preparing ${game.name}...";

      _statusColor = Colors.red;
    });

    try {
      await _launchSplashController.forward(
        from: 0.0,
      );
    } on TickerCanceled {
      return;
    }

    if (!mounted) return;

    setState(() {
      _showLaunchSplash = false;
      _launchSplashGame = null;
    });

    // Only launch/install after the full 4 seconds.
    await action();
  }

  // ============================================================
  // Install / Play
  // ============================================================

  Future<void> _handleInstallOrPlay(
      Game game,
      ) async {
    if (_isDownloading) return;

    if (_showLaunchSplash) return;

    // ==========================================================
    // Android: already installed
    // ==========================================================

    if (Platform.isAndroid) {
      final isInstalled =
          await InstalledApps.isAppInstalled(
            game.package,
          ) ??
              false;

      if (isInstalled) {
        await _showGameLaunchSplash(
          game,
              () async {
            if (!mounted) return;

            setState(() {
              _statusText =
              "Launching ${game.name}...";

              _statusColor = Colors.green;
            });

            debugPrint(
              'LAUNCHER: starting installed game '
                  '${game.name} (${game.package})',
            );

            await InstalledApps.startApp(
              game.package,
            );

            if (!_debugMode && mounted) {
              setState(() {
                _statusText =
                "Game Launched!";

                _statusColor = Colors.green;
              });
            }
          },
        );

        return;
      }
    }

    // ==========================================================
    // Existing downloaded file
    // ==========================================================

    final filePath = p.join(
      _downloadDir.path,
      Platform.isAndroid
          ? "${game.id}.apk"
          : "${game.id}.zip",
    );

    final file = File(filePath);

    if (file.existsSync()) {
      await _showGameLaunchSplash(
        game,
            () async {
          if (!mounted) return;

          setState(() {
            _statusText =
            Platform.isAndroid
                ? "Installing ${game.name}..."
                : "Launching ${game.name}...";

            _statusColor = Colors.orange;
          });

          debugPrint(
            'LAUNCHER: opening local game file '
                '${file.path}',
          );

          final result =
          await OpenFilex.open(
            filePath,
          );

          debugPrint(
            'LAUNCHER: OpenFilex result '
                'type=${result.type} '
                'message=${result.message}',
          );
        },
      );

      return;
    }

    // ==========================================================
    // Nothing downloaded -> download
    // ==========================================================

    await _startDownload(
      game,
      filePath,
    );
  }

  // ============================================================
  // Download
  // ============================================================

  Future<void> _startDownload(
      Game game,
      String filePath,
      ) async {
    if (_isDownloading) return;

    if (!mounted) return;

    setState(() {
      _isDownloading = true;
      _statusText =
      "Starting download...";
      _statusColor = Colors.orange;
      _progress = 0;
    });

    http.Client? client;
    IOSink? sink;

    try {
      client = http.Client();

      final request = http.Request(
        'GET',
        Uri.parse(
          Platform.isAndroid
              ? game.androidUrl
              : game.windowsUrl,
        ),
      );

      debugPrint(
        'LAUNCHER DOWNLOAD: ${request.url}',
      );

      final response =
      await client.send(request);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}',
        );
      }

      final total =
          response.contentLength ?? 0;

      var received = 0;

      final file = File(filePath);

      sink = file.openWrite();

      await response.stream.listen(
            (chunk) {
          received += chunk.length;

          sink!.add(chunk);

          if (total != 0 && mounted) {
            final progress =
                received / total;

            setState(() {
              _progress =
                  progress.clamp(0.0, 1.0);

              _statusText =
              "Downloading: "
                  "${(received / (1024 * 1024)).toStringAsFixed(1)} MB / "
                  "${(total / (1024 * 1024)).toStringAsFixed(1)} MB "
                  "(${(_progress * 100).toStringAsFixed(1)}%)";
            });
          }
        },
      ).asFuture();

      await sink.close();
      sink = null;

      client.close();
      client = null;

      if (!mounted) return;

      setState(() {
        _progress = 1;
        _isDownloading = false;

        _statusText =
        "Download complete!";

        _statusColor = Colors.green;
      });

      await _refreshAllStatus();

      /*
       * The downloaded file now exists.
       *
       * _handleInstallOrPlay() will consequently show
       * the game's 4-second splash using launchImage.
       */
      await _handleInstallOrPlay(game);
    } catch (e) {
      try {
        await sink?.close();
      } catch (_) {}

      try {
        client?.close();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _progress = 0;

        _statusText =
        "Download failed: $e";

        _statusColor = Colors.red;
      });

      debugPrint(
        'LAUNCHER DOWNLOAD ERROR: $e',
      );
    }
  }

  // ============================================================
  // Clear Cache
  // ============================================================

  Future<void> _clearCache(
      Game game,
      ) async {
    if (_showLaunchSplash) return;

    final filePath = p.join(
      _downloadDir.path,
      Platform.isAndroid
          ? "${game.id}.apk"
          : "${game.id}.zip",
    );

    final file = File(filePath);

    if (file.existsSync()) {
      await file.delete();

      if (!mounted) return;

      setState(() {
        _statusText =
        "Files cleared for ${game.name}";

        _statusColor = Colors.orange;
      });

      await _refreshAllStatus();
    } else {
      if (!mounted) return;

      setState(() {
        _statusText =
        "Nothing to clear";

        _statusColor = Colors.grey;
      });
    }
  }

  // ============================================================
  // FULL-SCREEN GAME LAUNCH SPLASH
  //
  // ONLY:
  //   1. Full-screen game-specific image.
  //   2. One circular progress ring in bottom-left.
  //
  // No text.
  // No countdown.
  // No linear progress bar.
  // No labels.
  // No other controls.
  // ============================================================

  Widget _buildGameLaunchSplash() {
    final game = _launchSplashGame;

    if (game == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: AnimatedBuilder(
          animation: _launchSplashController,
          builder: (context, child) {
            final progress =
                _launchSplashController.value;

            return Stack(
              fit: StackFit.expand,
              children: [
                // ==================================================
                // Full-screen game-specific splash image
                // ==================================================

                Image.asset(
                  game.launchImage,
                  fit: BoxFit.cover,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    debugPrint(
                      'LAUNCHER SPLASH IMAGE ERROR: '
                          '${game.launchImage}',
                    );

                    return Container(
                      color: Colors.black,
                    );
                  },
                ),

                // ==================================================
                // ONLY UI ELEMENT:
                // Progress ring in bottom-left
                // ==================================================

                Positioned(
                  left: 24,
                  bottom: 24,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child:
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor:
                      Colors.black.withValues(
                        alpha: 0.45,
                      ),
                      valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: Stack(
        children: [
          // ========================================================
          // Main Background
          // ========================================================

          Positioned.fill(
            child: Image.asset(
              _backgroundSrc,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) =>
                  Container(
                    color: Colors.black,
                  ),
            ),
          ),

          // ========================================================
          // Main Launcher UI
          // ========================================================

          SafeArea(
            child: Row(
              children: [
                // ====================================================
                // LEFT SIDE
                // ====================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ==============================================
                      // Header
                      // ==============================================

                      Padding(
                        padding:
                        const EdgeInsets.all(
                          16.0,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/launcher-title.png",
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                  ) =>
                              const Icon(
                                Icons.gamepad,
                                size: 48,
                                color: Colors.red,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            const Text(
                              "FazLauncher",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(
                              width: 20,
                            ),

                            const Text(
                              "v1.1.0 - Flutter Port",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontStyle:
                                FontStyle.italic,
                              ),
                            ),

                            const Spacer(),

                            if (_isDownloading)
                              Container(
                                width: 150,
                                padding:
                                const EdgeInsets
                                    .only(
                                  right: 10,
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    5,
                                  ),
                                  child:
                                  LinearProgressIndicator(
                                    value:
                                    _progress,
                                    minHeight: 8,
                                    color:
                                    const Color(
                                      0xFFB71C1C,
                                    ),
                                    backgroundColor:
                                    Colors
                                        .grey[900],
                                  ),
                                ),
                              ),

                            Text(
                              _statusText,
                              style: TextStyle(
                                color:
                                _statusColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==============================================
                      // Game Cards
                      // ==============================================

                      Expanded(
                        child:
                        ListView.builder(
                          controller:
                          _scrollController,
                          scrollDirection:
                          Axis.horizontal,
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          itemCount:
                          games.length,
                          itemBuilder: (
                              context,
                              index,
                              ) {
                            final game =
                            games[index];

                            final isSelected =
                                _selectedIndex ==
                                    index;

                            return Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                right: 20,
                              ),
                              child:
                              GestureDetector(
                                onTap: () {
                                  if (_showLaunchSplash ||
                                      _isDownloading) {
                                    return;
                                  }

                                  setState(() {
                                    _selectedIndex =
                                        index;
                                  });
                                },
                                child:
                                AnimatedContainer(
                                  duration:
                                  const Duration(
                                    milliseconds:
                                    300,
                                  ),
                                  width: 230,
                                  height: 700,
                                  decoration:
                                  BoxDecoration(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      15,
                                    ),
                                    border:
                                    Border.all(
                                      color:
                                      isSelected
                                          ? const Color(
                                        0xFFB71C1C,
                                      )
                                          : Colors
                                          .transparent,
                                      width: 3,
                                    ),
                                    boxShadow:
                                    isSelected
                                        ? [
                                      BoxShadow(
                                        color:
                                        const Color(
                                          0xFFB71C1C,
                                        ).withValues(
                                          alpha:
                                          0.5,
                                        ),
                                        blurRadius:
                                        10,
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child:
                                  Card(
                                    margin:
                                    EdgeInsets.zero,
                                    clipBehavior:
                                    Clip.antiAlias,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        12,
                                      ),
                                    ),
                                    elevation: 0,
                                    color: Colors
                                        .transparent,
                                    child:
                                    Stack(
                                      fit: StackFit
                                          .expand,
                                      children: [
                                        // ==================================
                                        // Game card image
                                        // ==================================

                                        Image.asset(
                                          game.image,
                                          fit: BoxFit
                                              .cover,
                                          errorBuilder:
                                              (
                                              context,
                                              error,
                                              stackTrace,
                                              ) =>
                                              Container(
                                                color:
                                                Colors.grey[900],
                                                child:
                                                const Icon(
                                                  Icons
                                                      .image,
                                                  size: 50,
                                                ),
                                              ),
                                        ),

                                        // ==================================
                                        // Status icon
                                        // ==================================

                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child:
                                          Icon(
                                            Icons
                                                .download_for_offline,
                                            size: 24,
                                            color:
                                            _getStatusColor(
                                              game.id,
                                            ),
                                          ),
                                        ),

                                        // ==================================
                                        // Action buttons
                                        // ==================================

                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child:
                                          Row(
                                            mainAxisSize:
                                            MainAxisSize
                                                .min,
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration:
                                                BoxDecoration(
                                                  color:
                                                  Colors.black.withValues(
                                                    alpha:
                                                    0.5,
                                                  ),
                                                  shape:
                                                  BoxShape.circle,
                                                ),
                                                child:
                                                IconButton(
                                                  icon:
                                                  const Icon(
                                                    Icons
                                                        .play_arrow,
                                                    color:
                                                    Colors.white,
                                                    size: 20,
                                                  ),
                                                  onPressed:
                                                  (_showLaunchSplash ||
                                                      _isDownloading)
                                                      ? null
                                                      : () =>
                                                      _handleInstallOrPlay(
                                                        game,
                                                      ),
                                                  padding:
                                                  EdgeInsets.zero,
                                                ),
                                              ),

                                              const SizedBox(
                                                width: 8,
                                              ),

                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration:
                                                BoxDecoration(
                                                  color:
                                                  Colors.black.withValues(
                                                    alpha:
                                                    0.5,
                                                  ),
                                                  shape:
                                                  BoxShape.circle,
                                                ),
                                                child:
                                                IconButton(
                                                  icon:
                                                  const Icon(
                                                    Icons
                                                        .delete_outline,
                                                    color:
                                                    Colors.white70,
                                                    size: 18,
                                                  ),
                                                  onPressed:
                                                  (_showLaunchSplash ||
                                                      _isDownloading)
                                                      ? null
                                                      : () =>
                                                      _clearCache(
                                                        game,
                                                      ),
                                                  padding:
                                                  EdgeInsets.zero,
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

                // ====================================================
                // SIDEBAR
                // ====================================================

                Container(
                  width: 70,
                  decoration:
                  BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.8,
                    ),
                    border:
                    const Border(
                      left:
                      BorderSide(
                        color:
                        Color(0xFFB71C1C),
                        width: 1,
                      ),
                    ),
                  ),
                  child:
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),

                      _SidebarButton(
                        icon:
                        Icons.photo_library,
                        label:
                        "Gallery",
                        onTap:
                        _showLaunchSplash ||
                            _isDownloading
                            ? () {}
                            : () {
                          Navigator
                              .push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                  context,
                                  ) =>
                              const GalleryPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _SidebarButton(
                        icon:
                        Icons.settings,
                        label:
                        "Settings",
                        onTap:
                        _showLaunchSplash ||
                            _isDownloading
                            ? () {}
                            : () {
                          Navigator
                              .push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                  context,
                                  ) =>
                              const SettingsPage(),
                            ),
                          ).then(
                                (_) {
                              _loadConfig();
                            },
                          );
                        },
                      ),

                      const Spacer(),

                      IconButton(
                        icon:
                        const Icon(
                          Icons.arrow_upward,
                          color:
                          Colors.white70,
                        ),
                        onPressed:
                        _showLaunchSplash ||
                            _isDownloading
                            ? null
                            : () {
                          _scrollController
                              .animateTo(
                            _scrollController
                                .offset -
                                200,
                            duration:
                            const Duration(
                              milliseconds:
                              300,
                            ),
                            curve:
                            Curves.easeOut,
                          );
                        },
                      ),

                      IconButton(
                        icon:
                        const Icon(
                          Icons.arrow_downward,
                          color:
                          Colors.white70,
                        ),
                        onPressed:
                        _showLaunchSplash ||
                            _isDownloading
                            ? null
                            : () {
                          _scrollController
                              .animateTo(
                            _scrollController
                                .offset +
                                200,
                            duration:
                            const Duration(
                              milliseconds:
                              300,
                            ),
                            curve:
                            Curves.easeOut,
                          );
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // FULL-SCREEN GAME LAUNCH SPLASH
          //
          // This MUST remain the final Stack child.
          // It covers the whole screen.
          // ==========================================================

          if (_showLaunchSplash)
            _buildGameLaunchSplash(),
        ],
      ),
    );
  }

  // ============================================================
  // Status Color
  // ============================================================

  Color _getStatusColor(
      String gameId,
      ) {
    final status =
    _gameFileStatus[gameId];

    if (status == "Installed") {
      return Colors.green;
    }

    if (status == "Downloaded") {
      return Colors.orange;
    }

    return Colors.red;
  }
}

// ============================================================
// Sidebar Button
// ============================================================

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            label,
            style: const TextStyle(
              color:
              Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}