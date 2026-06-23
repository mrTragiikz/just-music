import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  final Duration navigationDelay;

  const SplashScreen({super.key, this.navigationDelay = const Duration(milliseconds: 2600)});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _vinylController;
  late final AnimationController _equalizerController;
  late final AnimationController _notesController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _notesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _navigationTimer = Timer(widget.navigationDelay, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, _, _) => const AppShell(),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoController.dispose();
    _vinylController.dispose();
    _equalizerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          ..._buildFloatingNotes(scheme),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RotationTransition(
                        turns: _vinylController,
                        child: _VinylRecord(color: scheme.primary),
                      ),
                      FadeTransition(
                        opacity: _logoController,
                        child: ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _logoController,
                            curve: Curves.elasticOut,
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 48,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _equalizerController,
                  builder: (context, _) => _EqualizerBars(
                    animation: _equalizerController,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _logoController,
                  child: Column(
                    children: [
                      Text(
                        'OFFLINE MUSIC PLAYER',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: scheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'By Prabin Sharma',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
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

  List<Widget> _buildFloatingNotes(ColorScheme scheme) {
    final notes = ['♪', '♫', '♬'];
    return List.generate(6, (i) {
      final left = (i * 67) % 320 + 10.0;
      final delay = i * 0.15;
      return AnimatedBuilder(
        animation: _notesController,
        builder: (context, _) {
          final t = (_notesController.value + delay) % 1.0;
          final opacity = (sin(t * pi)).clamp(0.0, 1.0);
          return Positioned(
            left: left,
            bottom: 20 + t * 500,
            child: Opacity(
              opacity: opacity * 0.4,
              child: Text(
                notes[i % notes.length],
                style: TextStyle(fontSize: 18 + (i % 3) * 6, color: scheme.primary),
              ),
            ),
          );
        },
      );
    });
  }
}

class _VinylRecord extends StatelessWidget {
  final Color color;
  const _VinylRecord({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.black87],
          stops: const [0.0, 1.0],
          radius: 0.9,
        ),
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _EqualizerBars extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  const _EqualizerBars({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    final heights = [0.4, 0.9, 0.6, 1.0, 0.5];
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(heights.length, (i) {
          final phase = (animation.value + i * 0.2) % 1.0;
          final h = 8 + (heights[i] * 28 * (0.3 + 0.7 * sin(phase * pi)).abs());
          return Container(
            width: 5,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
