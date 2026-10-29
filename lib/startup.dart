import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/app_store.dart';
import 'core/theme/app_colors.dart';
import 'features/splash/splash_animations.dart';
import 'features/splash/splash_screen_widgets.dart';

class ArrowBoxStartup extends StatefulWidget {
  const ArrowBoxStartup({
    required this.storeLoader,
    this.firebaseInitializer,
    super.key,
  });

  final Future<AppStore> Function() storeLoader;
  final Future<void> Function()? firebaseInitializer;

  @override
  State<ArrowBoxStartup> createState() => _ArrowBoxStartupState();
}

class _ArrowBoxStartupState extends State<ArrowBoxStartup>
    with SingleTickerProviderStateMixin {
  late Future<AppStore> _storeFuture;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _storeFuture = _loadStore();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<AppStore> _loadStore() async {
    try {
      if (widget.firebaseInitializer != null) {
        await widget.firebaseInitializer!();
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
    return widget.storeLoader();
  }

  void _retry() {
    if (!mounted) return;
    setState(() {
      _storeFuture = _loadStore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArrowBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: FutureBuilder<AppStore>(
        future: _storeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return _ReadyApp(store: snapshot.data!);
          }
          if (snapshot.hasError) {
            return _StartupFailure(error: snapshot.error, onRetry: _retry);
          }
          return _StartupSplash(animation: _animationController);
        },
      ),
    );
  }
}

class _ReadyApp extends StatelessWidget {
  const _ReadyApp({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: ArrowBoxApp(key: ValueKey(store), store: store),
    );
  }
}

class _StartupSplash extends StatefulWidget {
  const _StartupSplash({required this.animation});

  final Animation<double> animation;

  @override
  State<_StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<_StartupSplash> {
  late Animation<double> _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = SplashAnimations.createEntranceAnimation(widget.animation as AnimationController);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entrance,
      child: Scaffold(
        backgroundColor: const Color(0xFF070D1A),
        body: Stack(
          children: [
            // Background Grid
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),
            // Floating Tiles
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SplashArrowTile(
                    icon: Icons.arrow_upward_rounded,
                    size: 48,
                    position: Offset(-80, -80),
                    rotation: 0.1,
                  ),
                  const SplashArrowTile(
                    icon: Icons.arrow_forward_rounded,
                    size: 48,
                    position: Offset(80, 80),
                    rotation: -0.2,
                  ),
                  // Central Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1628),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primaryBright.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.cyan,
                        size: 72,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // App Name, Tagline, Progress
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  const Text(
                    'ArrowBox',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escape the grid. Master the puzzle.',
                    style: TextStyle(color: Color(0xFF71839B), fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1628),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const LinearProgressIndicator(
                      color: AppColors.cyan,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preparing your puzzle...',
                    style: TextStyle(color: Color(0xFF71839B), fontSize: 12),
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBright.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StartupFailure extends StatelessWidget {
  const _StartupFailure({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.cyan, size: 48),
              const SizedBox(height: 20),
              const Text(
                'ArrowBox could not start',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your saved game was not changed. Try loading it again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB9C7DA), fontSize: 14),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
              if (error != null) const SizedBox(height: 12),
              if (error != null)
                Text(
                  '$error',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF71839B), fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
