import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_store.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/arrowbox_widgets.dart';

class ArrowBoxStartup extends StatefulWidget {
  const ArrowBoxStartup({required this.storeLoader, super.key});

  final Future<AppStore> Function() storeLoader;

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

class _StartupSplash extends StatelessWidget {
  const _StartupSplash({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final entrance = reduceMotion
        ? const AlwaysStoppedAnimation(1.0)
        : CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

    return Scaffold(
      backgroundColor: const Color(0xFF070D1A),
      body: Center(
        child: FadeTransition(
          opacity: entrance,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(entrance),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ArrowBoxLogoMark(size: 112),
                const SizedBox(height: 24),
                const Text(
                  'ArrowBox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preparing your game',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryBright,
                    backgroundColor: Color(0x3321D4FD),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
