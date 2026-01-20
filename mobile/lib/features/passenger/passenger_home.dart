import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/socket_service.dart';
import 'nganya_marker.dart';
import 'ratings_dialog.dart';
import 'leaderboard_screen.dart';

import '../auth/login_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final SocketService _socketService = SocketService();
  final MapController _mapController = MapController();
  final Map<String, Map<String, dynamic>> _nganyaData =
      {}; // {id: {location: LatLng, name: String}}

  // Default to Nairobi CBD
  final LatLng _initialCenter = const LatLng(-1.2921, 36.8219);

  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    // ghost fix: Do not load old cached locations. Start fresh.
    _initSocket();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentLocation!, 15.0);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void _initSocket() {
    _socketService.initSocket();
    _socketService.connect();

    _socketService.socket.on('nganyaLocationUpdate', (data) {
      if (mounted) {
        setState(() {
          final nganyaId = data['nganyaId'];
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          final name = data['name'] ?? nganyaId.split('-').first.toUpperCase();

          _nganyaData[nganyaId] = {'location': LatLng(lat, lng), 'name': name};
        });
      }
    });

    _socketService.socket.on('nganyaStatusUpdate', (data) {
      if (mounted) {
        setState(() {
          final nganyaId = data['nganyaId'];
          final isActive = data['isActive'];
          if (!isActive) {
            _nganyaData.remove(nganyaId);
          }
        });
      }
    });

    // Handle initial list if backend sends it (Optional but good practice)
    _socketService.socket.on('activeNganyas', (data) {
      if (mounted && data is List) {
        setState(() {
          _nganyaData.clear();
          for (var item in data) {
            final nganyaId = item['nganyaId'];
            final lat = (item['lat'] as num).toDouble();
            final lng = (item['lng'] as num).toDouble();
            final name =
                item['name'] ?? nganyaId.split('-').first.toUpperCase();
            _nganyaData[nganyaId] = {
              'location': LatLng(lat, lng),
              'name': name,
            };
          }
        });
      }
    });
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B), // Match Rating Dialog
        title: const Text(
          'Search Nganya',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter Nganya Name or ID',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.amber),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final query = searchController.text.toLowerCase();
              final match = _nganyaData.entries.where((entry) {
                final name =
                    entry.value['name']?.toString().toLowerCase() ?? '';
                final id = entry.key.toLowerCase();
                return name.contains(query) || id.contains(query);
              }).firstOrNull;

              Navigator.pop(context);

              if (match != null) {
                _mapController.move(match.value['location'], 15.0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Found ${match.value['name']}!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nganya not found or offline')),
                );
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NganyaRadar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Driver Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _initialCenter, initialZoom: 13.0),
        children: [
          TileLayer(
            // OpenStreetMap default
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.nganyaradar.app',
          ),
          MarkerLayer(
            markers: [
              // Passenger Location (Blue Dot)
              if (_currentLocation != null)
                Marker(
                  point: _currentLocation!,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              // Nganya Markers
              ..._nganyaData.entries.map((entry) {
                return Marker(
                  point: entry.value['location'],
                  width: 120,
                  height: 100,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => RatingsDialog(
                          nganyaId: entry.key,
                          nganyaName: entry.value['name'].toString(),
                        ),
                      );
                    },
                    child: NganyaMarker(name: entry.value['name']),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _showSearchDialog,
            heroTag: 'search_fab',
            tooltip: 'Search Nganya',
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 15.0);
              } else {
                _mapController.move(_initialCenter, 13.0);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location not valid yet')),
                );
              }
            },
            heroTag: 'locate_fab',
            tooltip: 'My Location',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
