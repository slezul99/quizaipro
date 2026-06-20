import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:quizaipro_mobile/core/config/app_config.dart';
import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/storage/secure_storage.dart';

/// WebSocket connection states.
enum WsConnectionState { disconnected, connecting, connected, reconnecting }

/// Single multiplexed WebSocket connection.
///
/// Architecture:
///   - One connection per app session (keepAlive Riverpod provider)
///   - Rooms are multiplexed over the same socket via JSON envelope:
///       { "room": "chat:42", "event": "message.new", "seq": 1, "data": {...} }
///   - Reconnects with exponential backoff on abnormal close
///   - Heartbeat ping every [AppConstants.wsPingIntervalMs] ms
///   - Seq tracking per room — gap detected → room-level REST resync
///
/// This class is a shell; full implementation ships in P4 (Social features).
class WebSocketManager {
  WebSocketManager({
    required SecureStorage secureStorage,
  }) : _secureStorage = secureStorage;

  final SecureStorage _secureStorage;

  final _stateController =
      StreamController<WsConnectionState>.broadcast();
  final _eventController =
      StreamController<WsEvent>.broadcast();

  WsConnectionState _state = WsConnectionState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  // Per-room sequence numbers for gap detection.
  final Map<String, int> _roomSeq = {};

  WsConnectionState get state => _state;

  Stream<WsConnectionState> get onStateChange => _stateController.stream;

  Stream<WsEvent> get onEvent => _eventController.stream;

  Stream<WsEvent> eventsForRoom(String room) =>
      _eventController.stream.where((e) => e.room == room);

  Future<void> connect() async {
    if (_state == WsConnectionState.connected ||
        _state == WsConnectionState.connecting) return;

    _setState(WsConnectionState.connecting);

    final token = await _secureStorage.readAccessToken();
    if (token == null) {
      _setState(WsConnectionState.disconnected);
      return;
    }

    final uri = Uri.parse(
      '${AppConfig.instance.wsBaseUrl}?token=${Uri.encodeComponent(token)}',
    );

    debugPrint('[WS] Connecting to $uri');
    // Full WebSocket implementation added in P4.
    // Stub: mark as connected for provider graph completeness.
    _setState(WsConnectionState.connected);
    _reconnectAttempts = 0;
    _startPing();
  }

  void disconnect() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _setState(WsConnectionState.disconnected);
  }

  void joinRoom(String room) {
    _send({'action': 'join', 'room': room});
  }

  void leaveRoom(String room) {
    _send({'action': 'leave', 'room': room});
    _roomSeq.remove(room);
  }

  void send(String room, String event, Map<String, dynamic> data) {
    _send({'room': room, 'event': event, 'data': data});
  }

  void _send(Map<String, dynamic> payload) {
    if (_state != WsConnectionState.connected) return;
    debugPrint('[WS] → ${jsonEncode(payload)}');
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.wsPingIntervalMs),
      (_) => _send({'action': 'ping'}),
    );
  }

  void _setState(WsConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  int _nextReconnectDelayMs() {
    final delay = AppConstants.wsInitialReconnectDelayMs *
        (1 << _reconnectAttempts.clamp(0, 6));
    return delay.clamp(
      AppConstants.wsInitialReconnectDelayMs,
      AppConstants.wsMaxReconnectDelayMs,
    );
  }

  Future<void> dispose() async {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    await _stateController.close();
    await _eventController.close();
  }
}

/// An event received over the WebSocket.
class WsEvent {
  const WsEvent({
    required this.room,
    required this.event,
    required this.seq,
    required this.data,
  });

  factory WsEvent.fromJson(Map<String, dynamic> json) => WsEvent(
        room: json['room'] as String,
        event: json['event'] as String,
        seq: json['seq'] as int? ?? 0,
        data: json['data'] as Map<String, dynamic>? ?? const {},
      );

  final String room;
  final String event;
  final int seq;
  final Map<String, dynamic> data;
}
