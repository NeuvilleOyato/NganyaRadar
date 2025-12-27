import 'dart:async';
import 'package:flutter/material.dart';

class RotatingBackground extends StatefulWidget {
  final List<String> images;
  const RotatingBackground({super.key, required this.images});

  @override
  State<RotatingBackground> createState() => _RotatingBackgroundState();
}

class _RotatingBackgroundState extends State<RotatingBackground> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(seconds: 2),
          child: Container(
            key: ValueKey<int>(_currentIndex),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.images[_currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.4),
                Colors.black.withValues(alpha: 0.6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
