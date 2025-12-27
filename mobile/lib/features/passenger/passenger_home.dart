import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/socket_service.dart';
import 'nganya_marker.dart';
import 'ratings_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCachedLocations();
    _initSocket();
  }

  Future<void> _loadCachedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('cached_nganya_locations');
    if (cachedData != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(cachedData);
        setState(() {
          jsonMap.forEach((key, value) {
            final Map<String, dynamic> data = value as Map<String, dynamic>;
            _nganyaData[key] = {
              'location': LatLng(data['lat'], data['lng']),
              'name': data['name'] ?? key.split('-').first.toUpperCase(),
            };
          });
        });
      } catch (e) {
        debugPrint('Error loading cached locations: $e');
      }
    }
  }

  Future<void> _persistLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> exportMap = {};
    _nganyaData.forEach((key, value) {
      final LatLng loc = value['location'];
      exportMap[key] = {
        'lat': loc.latitude,
        'lng': loc.longitude,
        'name': value['name'],
      };
    });
    await prefs.setString('cached_nganya_locations', jsonEncode(exportMap));
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
        _persistLocations();
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
        _persistLocations();
      }
    });
  }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Nganya'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Enter Nganya Name or ID',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
            markers: _nganyaData.entries.map((entry) {
              return Marker(
                point: entry.value['location'],
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => RatingsDialog(nganyaId: entry.key),
                    );
                  },
                  child: NganyaMarker(name: entry.value['name']),
                ),
              );
            }).toList(),
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
              _mapController.move(_initialCenter, 13.0);
            },
            heroTag: 'locate_fab',
            tooltip: 'Center Map',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
