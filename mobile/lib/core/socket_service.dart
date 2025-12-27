import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'constants.dart';

class SocketService {
  late io.Socket socket;

  void initSocket() {
    socket = io.io(AppConstants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      debugPrint('Connected to Socket.io server');
    });

    socket.onDisconnect(
      (_) => debugPrint('Disconnected from Socket.io server'),
    );
  }

  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  void disconnect() {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  void emitLocationUpdate(String nganyaId, double lat, double lng) {
    socket.emit('updateLocation', {
      'nganyaId': nganyaId,
      'lat': lat,
      'lng': lng,
    });
  }

  void emitServiceStatus(String nganyaId, bool isActive) {
    socket.emit('updateServiceStatus', {
      'nganyaId': nganyaId,
      'isActive': isActive,
    });
  }
}
