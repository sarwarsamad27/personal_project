import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  Completer<IO.Socket?>? _connectCompleter;
  bool _isConnecting = false;

  /// baseUrl example: http://10.0.2.2:5000
  /// path example: /socket.io  (default) OR whatever backend uses
  Future<IO.Socket?> ensureConnected({
    required String baseUrl,
    required String token,
    String path = "/socket.io",
  }) async {
    if (_socket != null && _socket!.connected) return _socket;

    if (_isConnecting && _connectCompleter != null) {
      return _connectCompleter!.future;
    }

    _isConnecting = true;
    _connectCompleter = Completer<IO.Socket?>();

    try {
      try {
        _socket?.dispose();
      } catch (_) {}
      _socket = null;

      final s = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setPath(path) // IMPORTANT
            .setTransports(['websocket', 'polling']) // IMPORTANT (do not force websocket only)
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(800)
            .setTimeout(8000)
            .setAuth({'token': token}) // adjust if backend expects different key
            .build(),
      );

      _socket = s;

      s.onConnect((_) {
        print("✅ Socket CONNECTED. id=${s.id}");
        if (!(_connectCompleter?.isCompleted ?? true)) {
          _connectCompleter?.complete(s);
        }
      });

      s.onConnectError((err) {
        print("❌ Socket CONNECT ERROR: $err");
        if (!(_connectCompleter?.isCompleted ?? true)) {
          _connectCompleter?.complete(null);
        }
      });

      s.onError((err) {
        print("❌ Socket ERROR: $err");
      });

      s.onDisconnect((_) {
        print("⚠️ Socket DISCONNECTED");
      });

      s.connect();

      final result = await _connectCompleter!.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          print("❌ Socket connect TIMEOUT");
          return null;
        },
      );

      return result;
    } finally {
      _isConnecting = false;
    }
  }

  void joinThread(String threadId) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit("chat:join", {"threadId": threadId});
    print("✅ Joined room: $threadId");
  }

  void leaveThread(String threadId) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit("chat:leave", {"threadId": threadId});
    print("✅ Left room: $threadId");
  }

  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    _connectCompleter = null;
    _isConnecting = false;
  }
}
