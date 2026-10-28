import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../arrow_lab/arrow_lab_screen.dart';
import 'floating_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.store, super.key});

  final AppStore store;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _LazyTab(
        active: _index == 0,
        builder: () => WelcomeScreen(store: widget.store),
      ),
      _LazyTab(
        active: _index == 1,
        builder: () =>
            LevelSelectionScreen(store: widget.store, embedded: true),
      ),
      _LazyTab(
        active: _index == 2,
        builder: () => ArrowLabScreen(store: widget.store),
      ),
      _LazyTab(
        active: _index == 3,
        builder: () => ProgressScreen(store: widget.store, embedded: true),
      ),
      _LazyTab(
        active: _index == 4,
        builder: () => SettingsScreen(store: widget.store, embedded: true),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          IndexedStack(index: _index, children: pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              index: _index,
              onChanged: (value) => setState(() => _index = value),
            ),
          ),
        ],
      ),
    );
  }
}

class _LazyTab extends StatefulWidget {
  const _LazyTab({required this.active, required this.builder});

  final bool active;
  final Widget Function() builder;

  @override
  State<_LazyTab> createState() => _LazyTabState();
}

class _LazyTabState extends State<_LazyTab> {
  Widget? _child;

  @override
  void didUpdateWidget(covariant _LazyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && _child == null) {
      _child = widget.builder();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.active && _child == null) {
      _child = widget.builder();
    }
    return _child ?? const SizedBox.shrink();
  }
}
