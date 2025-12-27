import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/location_service.dart';
import '../../core/socket_service.dart';

import '../../core/widgets/glass_container.dart';

import '../../core/widgets/rotating_background.dart';

class DriverHomeScreen extends StatefulWidget {
  final String nganyaId;

  const DriverHomeScreen({super.key, required this.nganyaId});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final LocationService _locationService = LocationService();
  final SocketService _socketService = SocketService();

  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;

  final List<String> _bgImages = [
    'assets/images/backgrounds/fest.jpg',
    'assets/images/backgrounds/fest2.jpg',
    'assets/images/backgrounds/matrix.jpg',
    'assets/images/backgrounds/oppo.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();
    _socketService.connect();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _socketService.disconnect();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    if (widget.nganyaId.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Vehicle Assigned'),
            content: const Text(
              'Your account does not have a vehicle assigned. Please logout and create a NEW account to automatically get a vehicle.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (_isTracking) {
      await _positionSubscription?.cancel();
      _socketService.emitServiceStatus(widget.nganyaId, false);
      setState(() {
        _isTracking = false;
      });
    } else {
      bool hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }

      _socketService.emitServiceStatus(widget.nganyaId, true);
      setState(() {
        _isTracking = true;
      });

      _positionSubscription = _locationService.getPositionStream().listen(
        (Position position) {
          _socketService.emitLocationUpdate(
            widget.nganyaId,
            position.latitude,
            position.longitude,
          );
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Location Error: $e')));
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          RotatingBackground(images: _bgImages),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_isTracking ? Colors.green : Colors.red)
                                .withValues(alpha: 0.1),
                            border: Border.all(
                              color: (_isTracking ? Colors.green : Colors.red)
                                  .withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/branding/app_icon.png',
                          width: 80,
                          color: _isTracking
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          colorBlendMode: BlendMode.modulate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isTracking ? 'Service Online' : 'Service Offline',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bus ID: ${widget.nganyaId.split("-").first}...',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _toggleTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTracking
                            ? Colors.redAccent.withValues(alpha: 0.8)
                            : Colors.greenAccent.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        elevation: 8,
                        shadowColor: Colors.black45,
                      ),
                      child: Text(
                        _isTracking ? 'STOP SERVICE' : 'START SERVICE',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isTracking)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.greenAccent,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Broadcasting location...',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
