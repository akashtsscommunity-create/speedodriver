// ═══════════════════════════════════════════════════════════════════════════════
// websocket_client.dart — Production-Grade WebSocket + REST Client for Flutter
// Email Template Designer — Real-Time Collaboration & Push Updates
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

/// Connection state enum. Emitted via [WsClient.stateStream].
enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Configuration for both WebSocket and REST clients.
class ClientConfig {
  final String wsBaseUrl;
  final String httpBaseUrl;
  final Duration heartbeatInterval;
  final Duration heartbeatTimeout;
  final Duration initialReconnectDelay;
  final Duration maxReconnectDelay;
  final double reconnectBackoffMultiplier;
  final double reconnectJitterFraction;
  final int maxReconnectAttempts;
  final Duration batchIdleDelay;
  final Duration batchMaxDelay;
  final Duration httpTimeout;
  final int httpRetryAttempts;

  const ClientConfig({
    this.wsBaseUrl = 'ws://localhost:5001',
    this.httpBaseUrl = 'http://localhost:5001',
    this.heartbeatInterval = const Duration(seconds: 10),
    this.heartbeatTimeout = const Duration(seconds: 30),
    this.initialReconnectDelay = const Duration(seconds: 1),
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.reconnectBackoffMultiplier = 2.0,
    this.reconnectJitterFraction = 0.25,
    this.maxReconnectAttempts = 0,
    this.batchIdleDelay = const Duration(milliseconds: 250),
    this.batchMaxDelay = const Duration(milliseconds: 1500),
    this.httpTimeout = const Duration(seconds: 30),
    this.httpRetryAttempts = 3,
  });
}

/// Represents a remote user in the same editing session.
class WsCollaborator {
  final String id;
  final String displayName;
  final int colorIndex;
  final String? nodeId;
  final String? fieldPath;

  WsCollaborator({
    required this.id,
    required this.displayName,
    this.colorIndex = 0,
    this.nodeId,
    this.fieldPath,
  });

  WsCollaborator copyWith({String? nodeId, String? fieldPath}) => WsCollaborator(
    id: id,
    displayName: displayName,
    colorIndex: colorIndex,
    nodeId: nodeId ?? this.nodeId,
    fieldPath: fieldPath ?? this.fieldPath,
  );
}

/// Production-grade WebSocket client for Flutter.
class WsClient {
  final ClientConfig config;

  WsConnectionState _state = WsConnectionState.disconnected;
  WebSocket? _ws;
  String? _templateId;
  String? _userId;
  String? _displayName;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  DateTime _lastServerMessageAt = DateTime.now();
  int _serverSeq = 0;
  final Map<String, WsCollaborator> _collaborators = {};

  final _stateController = StreamController<WsConnectionState>.broadcast();
  final _opController = StreamController<Map<String, dynamic>>.broadcast();
  final _cursorController = StreamController<Map<String, dynamic>>.broadcast();
  final _joinController = StreamController<WsCollaborator>.broadcast();
  final _leaveController = StreamController<String>.broadcast();
  final _welcomeController = StreamController<Map<String, dynamic>>.broadcast();
  final _ackController = StreamController<Map<String, dynamic>>.broadcast();
  final _savedController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<Map<String, dynamic>>.broadcast();
  final _conflictController = StreamController<Map<String, dynamic>>.broadcast();

  final List<Map<String, dynamic>> _batchBuffer = [];
  Timer? _batchIdleTimer;
  Timer? _batchMaxTimer;
  final List<Map<String, dynamic>> _offlineQueue = [];

  WsClient({this.config = const ClientConfig()});

  Stream<WsConnectionState> get stateStream => _stateController.stream;
  Stream<Map<String, dynamic>> get onOp => _opController.stream;
  Stream<Map<String, dynamic>> get onCursor => _cursorController.stream;
  Stream<WsCollaborator> get onJoin => _joinController.stream;
  Stream<String> get onLeave => _leaveController.stream;
  Stream<Map<String, dynamic>> get onWelcome => _welcomeController.stream;
  Stream<Map<String, dynamic>> get onAck => _ackController.stream;
  Stream<Map<String, dynamic>> get onSaved => _savedController.stream;
  Stream<Map<String, dynamic>> get onError => _errorController.stream;
  Stream<Map<String, dynamic>> get onConflict => _conflictController.stream;

  WsConnectionState get state => _state;
  bool get isConnected => _state == WsConnectionState.connected;
  Map<String, WsCollaborator> get collaborators => Map.unmodifiable(_collaborators);
  int get serverSeq => _serverSeq;
  int get reconnectAttempt => _reconnectAttempt;

  Future<void> connect(String templateId, String userId, String displayName) async {
    _templateId = templateId;
    _userId = userId;
    _displayName = displayName;
    _reconnectAttempt = 0;
    _collaborators.clear();
    await _doConnect();
  }

  Future<void> _doConnect() async {
    _setState(WsConnectionState.connecting);
    final url = '${config.wsBaseUrl}/ws/collab/$_templateId'
        '?userId=${Uri.encodeComponent(_userId!)}'
        '&displayName=${Uri.encodeComponent(_displayName!)}';

    try {
      _ws = await WebSocket.connect(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw SocketException('WebSocket connection timed out'),
      );

      _setState(WsConnectionState.connected);
      _reconnectAttempt = 0;
      _lastServerMessageAt = DateTime.now();
      _startHeartbeat();

      if (_offlineQueue.isNotEmpty) {
        final queue = List<Map<String, dynamic>>.from(_offlineQueue);
        _offlineQueue.clear();
        _send({'type': 'op', 'ops': queue, 'baseRev': _serverSeq});
      }

      _ws!.listen(
        (data) {
          _lastServerMessageAt = DateTime.now();
          if (data is String) _handleMessage(data);
        },
        onDone: () {
          _stopHeartbeat();
          if (_state != WsConnectionState.disconnected) _scheduleReconnect();
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _setState(WsConnectionState.disconnected);
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _clearBatchTimers();
    _flushBatch();
    if (_ws != null) {
      try { _ws!.close(1000, 'Client disconnecting'); } catch (_) {}
      _ws = null;
    }
    _collaborators.clear();
  }

  void _scheduleReconnect() {
    if (_state == WsConnectionState.disconnected) return;
    _reconnectAttempt++;
    if (config.maxReconnectAttempts > 0 && _reconnectAttempt > config.maxReconnectAttempts) {
      _setState(WsConnectionState.disconnected);
      return;
    }

    final baseDelayMs = config.initialReconnectDelay.inMilliseconds *
        pow(config.reconnectBackoffMultiplier, _reconnectAttempt - 1);
    final cappedMs = min(baseDelayMs, config.maxReconnectDelay.inMilliseconds.toDouble());
    final jitter = cappedMs * config.reconnectJitterFraction * (Random().nextDouble() * 2 - 1);
    final finalMs = (cappedMs + jitter).round();

    _setState(WsConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: finalMs), () {
      _reconnectTimer = null;
      _doConnect();
    });
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(config.heartbeatInterval, (_) {
      _send({'type': 'heartbeat'});
      if (DateTime.now().difference(_lastServerMessageAt) > config.heartbeatTimeout) {
        try { _ws?.close(4000, 'Heartbeat timeout'); } catch (_) {}
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _handleMessage(String rawData) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) { return; }

    final type = msg['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'welcome':
        _serverSeq = (msg['serverSeq'] as num?)?.toInt() ?? 0;
        _collaborators.clear();
        final collabs = msg['collaborators'] as List<dynamic>? ?? [];
        for (final c in collabs) {
          final id = c['id']?.toString() ?? '';
          _collaborators[id] = WsCollaborator(
            id: id,
            displayName: c['displayName'] ?? 'Anonymous',
            colorIndex: (c['colorIndex'] as num?)?.toInt() ?? 0,
          );
        }
        _welcomeController.add(msg);
        break;
      case 'op':
        final seq = (msg['serverSeq'] as num?)?.toInt();
        if (seq != null) _serverSeq = seq;
        _opController.add(msg);
        break;
      case 'cursor':
        final actorId = msg['actorId']?.toString();
        if (actorId != null) {
          final existing = _collaborators[actorId];
          _collaborators[actorId] = WsCollaborator(
            id: actorId,
            displayName: msg['displayName']?.toString() ?? existing?.displayName ?? 'Anonymous',
            colorIndex: (msg['colorIndex'] as num?)?.toInt() ?? existing?.colorIndex ?? 0,
            nodeId: msg['nodeId']?.toString(),
            fieldPath: msg['fieldPath']?.toString(),
          );
        }
        _cursorController.add(msg);
        break;
      case 'join':
        final actorId = msg['actorId']?.toString() ?? '';
        final collab = WsCollaborator(
          id: actorId,
          displayName: msg['displayName']?.toString() ?? 'Anonymous',
          colorIndex: (msg['colorIndex'] as num?)?.toInt() ?? 0,
        );
        _collaborators[actorId] = collab;
        _joinController.add(collab);
        break;
      case 'leave':
        final actorId = msg['actorId']?.toString() ?? '';
        _collaborators.remove(actorId);
        _leaveController.add(actorId);
        break;
      case 'ack':
        final seq = (msg['serverSeq'] as num?)?.toInt();
        if (seq != null) _serverSeq = seq;
        _ackController.add(msg);
        break;
      case 'saved':
        _savedController.add(msg);
        break;
      case 'conflict':
        _conflictController.add(msg);
        break;
      case 'error':
        _errorController.add(msg);
        break;
    }
  }

  void sendOp(Map<String, dynamic> op) {
    if (_state != WsConnectionState.connected) {
      _offlineQueue.add(op);
      return;
    }
    _batchBuffer.add(op);
    _batchIdleTimer?.cancel();
    _batchIdleTimer = Timer(config.batchIdleDelay, _flushBatch);
    _batchMaxTimer ??= Timer(config.batchMaxDelay, _flushBatch);
  }

  void sendCursor(String nodeId, [String? fieldPath]) {
    _send({'type': 'cursor', 'nodeId': nodeId, 'fieldPath': fieldPath});
  }

  void _flushBatch() {
    _clearBatchTimers();
    if (_batchBuffer.isEmpty) return;
    final ops = List<Map<String, dynamic>>.from(_batchBuffer);
    _batchBuffer.clear();
    _send({'type': 'op', 'ops': ops, 'baseRev': _serverSeq});
  }

  void _clearBatchTimers() {
    _batchIdleTimer?.cancel();
    _batchIdleTimer = null;
    _batchMaxTimer?.cancel();
    _batchMaxTimer = null;
  }

  bool _send(Map<String, dynamic> data) {
    if (_ws == null || _ws!.readyState != WebSocket.open) return false;
    try {
      _ws!.add(jsonEncode(data));
      return true;
    } catch (_) { return false; }
  }

  void _setState(WsConnectionState newState) {
    if (_state == newState) return;
    _state = newState;
    _stateController.add(newState);
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _opController.close();
    _cursorController.close();
    _joinController.close();
    _leaveController.close();
    _welcomeController.close();
    _ackController.close();
    _savedController.close();
    _errorController.close();
    _conflictController.close();
  }
}

/// Custom exception for REST API errors.
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final String? correlationId;
  ApiException(this.statusCode, this.code, this.message, [this.correlationId]);
  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

/// REST API client.
class RestClient {
  final ClientConfig config;
  final HttpClient _http;
  final Future<String?> Function()? getAuthToken;

  RestClient({this.config = const ClientConfig(), this.getAuthToken})
      : _http = HttpClient()..connectionTimeout = config.httpTimeout;

  Future<Map<String, dynamic>> request(String method, String path, {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    final correlationId = DateTime.now().millisecondsSinceEpoch.toString();
    var urlStr = '${config.httpBaseUrl}$path';
    if (queryParams != null && queryParams.isNotEmpty) {
      urlStr += '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    }

    for (int attempt = 0; attempt <= config.httpRetryAttempts; attempt++) {
      if (attempt > 0) await Future.delayed(Duration(seconds: attempt));
      try {
        final uri = Uri.parse(urlStr);
        final req = await _http.openUrl(method, uri);
        req.headers.set('Content-Type', 'application/json');
        req.headers.set('X-Correlation-ID', correlationId);
        if (getAuthToken != null) {
          final token = await getAuthToken!();
          if (token != null) req.headers.set('Authorization', 'Bearer $token');
        }
        if (body != null) req.write(jsonEncode(body));
        final resp = await req.close();
        final respBody = await resp.transform(utf8.decoder).join();
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return respBody.isEmpty ? {} : jsonDecode(respBody);
        }
        if (resp.statusCode < 500) throw ApiException(resp.statusCode, 'CLIENT_ERROR', respBody, correlationId);
      } catch (e) {
        if (attempt == config.httpRetryAttempts) rethrow;
      }
    }
    throw ApiException(0, 'UNKNOWN', 'Failed after retries');
  }

  void dispose() => _http.close();
}
