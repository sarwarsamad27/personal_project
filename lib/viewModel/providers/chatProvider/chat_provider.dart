import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:new_brand/models/chatThread/chatModel.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/repository/chatThread/exchangeDisicion_repository.dart';

class CompanyChatProvider extends ChangeNotifier with WidgetsBindingObserver {
  final String threadId;
  final String toType;
  final String toId;
  final String title;
  final String? buyerImage;

  CompanyChatProvider({
    required this.threadId,
    required this.toType,
    required this.toId,
    required this.title,
    required this.buyerImage,
  });

  // ===== Controllers owned by UI widgets =====
  final TextEditingController msgController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ===== State =====
  final List<ChatMessage> messages = [];
  bool isTyping = false;
  bool isProcessing = false;
  bool isLoadingHistory = true;

  // ===== Typing =====
  Timer? _typingTimer;
  String? _lastTypingValue;

  // ===== Dedupe =====
  final Set<String> _processedMessageIds = {};
  final Set<String> _processedClientIds = {};
  final Map<String, DateTime> _recentKeys = {};
  bool _listenersBound = false;

  // =========================
  // Init / Dispose
  // =========================
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    try {
      final token = await LocalStorage.getToken();
      final baseUrl = Global.imageUrl;

      if (token == null || token.isEmpty) {
        isLoadingHistory = false;
        notifyListeners();
        return;
      }

      await _loadChatHistory(token, baseUrl);

      final s = await SocketService().ensureConnected(
        baseUrl: baseUrl,
        token: token,
      );

      if (s == null) {
        isLoadingHistory = false;
        notifyListeners();
        return;
      }

      SocketService().joinThread(threadId);
      _setupSocketListeners();

      _markMessagesAsDelivered();
      _markMessagesAsRead();
    } catch (_) {
      // ignore
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    SocketService().leaveThread(threadId);

    msgController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // =========================
  // Helpers
  // =========================
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String imgUrl(String path) {
    if (path.startsWith("http://") || path.startsWith("https://")) return path;
    return "${Global.imageUrl}/$path";
  }

  String normalizeStatus(String? s) {
    final v = (s ?? "pending").toLowerCase();
    if (v == "denied") return "rejected";
    if (v == "reject") return "rejected";
    if (v == "approved") return "accepted";
    return v;
  }

  // fingerprint key
  String _key({required String? fromType, required String? text, required String? ts}) {
    final t = (text ?? "").trim();
    String s = (ts ?? "").toString();
    if (s.length >= 19) s = s.substring(0, 19);
    return "${fromType ?? ""}|$t|$s";
  }

  // loose key to stop duplicates if timestamp differs
  String _loose({required String? fromType, required String? text}) {
    final t = (text ?? "").trim();
    return "${fromType ?? ""}|$t";
  }

  bool _isRecentDup(String k, {int seconds = 6}) {
    final now = DateTime.now();
    _recentKeys.removeWhere((_, t) => now.difference(t).inSeconds > seconds);

    final last = _recentKeys[k];
    if (last != null && now.difference(last).inSeconds <= seconds) return true;

    _recentKeys[k] = now;
    return false;
  }

  // =========================
  // History
  // =========================
  Future<void> _loadChatHistory(String token, String baseUrl) async {
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/api/chat/messages/$threadId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode != 200) return;

      final data = json.decode(resp.body);
      final List<dynamic> messagesData = data['messages'] ?? [];

      messages.clear();
      _processedMessageIds.clear();
      _processedClientIds.clear();
      _recentKeys.clear();

      for (var msgData in messagesData.reversed) {
        final msg = ChatMessage.fromJson(Map<String, dynamic>.from(msgData));
        messages.add(msg);
        if (msg.id != null) _processedMessageIds.add(msg.id!);
        _recentKeys[_key(fromType: msg.fromType, text: msg.text, ts: msg.timestamp)] = DateTime.now();
      }

      notifyListeners();
    } catch (_) {}
  }

  // =========================
  // Socket Listeners
  // =========================
  void _setupSocketListeners() {
    if (_listenersBound) return;
    _listenersBound = true;

    final socket = SocketService().socket;
    if (socket == null) return;

    socket.off("chat:message");
    socket.off("exchange:new");
    socket.off("exchange:status");
    socket.off("chat:typing");
    socket.off("chat:status");
    socket.off("chat:status_bulk");

    // ------- chat:message -------
    socket.on("chat:message", (data) {
      if (data is! Map) return;
      if (data["threadId"]?.toString() != threadId) return;

      final messageId = (data["_id"] ?? data["id"])?.toString();
      final clientId = data["clientId"]?.toString();
      final fromType = data["fromType"]?.toString();
      final incomingTs = (data["timestamp"] ?? data["createdAt"])?.toString();
      final incomingText = data["text"]?.toString();

      // ✅ dedupe
      final fp = _key(fromType: fromType, text: incomingText, ts: incomingTs);
      if (_isRecentDup(fp)) return;

      // seller msg timestamp mismatch case
      if (fromType == "seller") {
        final lk = _loose(fromType: fromType, text: incomingText);
        if (_isRecentDup(lk)) return;
      }

      if (clientId != null && _processedClientIds.contains(clientId)) return;
      if (messageId != null && _processedMessageIds.contains(messageId)) return;

      final newMessage = ChatMessage.fromJson(Map<String, dynamic>.from(data));

      messages.insert(0, newMessage);
      if (newMessage.id != null) _processedMessageIds.add(newMessage.id!);
      if (clientId != null) _processedClientIds.add(clientId);

      // statuses for buyer msgs
      if (newMessage.fromType != "seller" && newMessage.id != null) {
        _markSingleMessageDelivered(newMessage.id!);
        _markSingleMessageRead(newMessage.id!);
      }

      notifyListeners();
      scrollToBottom();
    });

    // ------- exchange:new -------
    socket.on("exchange:new", (data) {
      if (data is! Map) return;
      if (data["threadId"]?.toString() != threadId) return;

      final messageId = (data["_id"] ?? data["id"])?.toString();
      if (messageId != null && _processedMessageIds.contains(messageId)) return;

      try {
        final exchangeMessage = ChatMessage(
          id: messageId,
          threadId: threadId,
          fromType: "buyer",
          isExchangeRequest: true,
          timestamp: data["timestamp"]?.toString() ??
              data["createdAt"]?.toString() ??
              DateTime.now().toIso8601String(),
          text: data["text"]?.toString(),
          exchangeData: ExchangeRequestData(
            exchangeId: data["exchangeData"]?["exchangeId"]?.toString() ??
                data["exchangeRequestId"]?.toString(),
            orderId: data["exchangeData"]?["orderId"]?.toString(),
            productId: data["exchangeData"]?["productId"]?.toString(),
            productName: data["exchangeData"]?["productName"]?.toString(),
            reason: data["exchangeData"]?["reason"]?.toString(),
            status: (data["exchangeData"]?["status"]?.toString() ?? "Pending").toString(),
            createdAt: data["exchangeData"]?["createdAt"]?.toString(),
            images: ((data["exchangeData"]?["images"] as List?) ?? const [])
                .map((e) => e.toString())
                .toList(),
          ),
        );

        messages.insert(0, exchangeMessage);
        if (messageId != null) _processedMessageIds.add(messageId);

        notifyListeners();
        scrollToBottom();
      } catch (_) {}
    });

    // ------- exchange:status -------
    socket.on("exchange:status", (data) {
      if (data is! Map) return;

      final exchangeId = data["exchangeRequestId"]?.toString();
      final newStatus = data["status"]?.toString();
      if (exchangeId == null || newStatus == null) return;

      for (int i = 0; i < messages.length; i++) {
        if (messages[i].isExchangeRequest == true &&
            messages[i].exchangeData?.exchangeId == exchangeId) {
          final old = messages[i];
          messages[i] = ChatMessage(
            id: old.id,
            threadId: old.threadId,
            fromType: old.fromType,
            isExchangeRequest: true,
            timestamp: old.timestamp,
            text: old.text,
            deliveredAt: old.deliveredAt,
            readAt: old.readAt,
            exchangeData: ExchangeRequestData(
              exchangeId: old.exchangeData?.exchangeId,
              orderId: old.exchangeData?.orderId,
              productId: old.exchangeData?.productId,
              productName: old.exchangeData?.productName,
              reason: old.exchangeData?.reason,
              status: newStatus,
              createdAt: old.exchangeData?.createdAt,
              images: old.exchangeData?.images ?? const [],
            ),
          );
          break;
        }
      }
      notifyListeners();
    });

    // ------- typing -------
    socket.on("chat:typing", (data) {
      if (data is Map && data["threadId"] == threadId) {
        isTyping = (data["isTyping"] ?? false) == true;
        notifyListeners();
      }
    });

    // ------- status single -------
    socket.on("chat:status", (data) {
      if (data is! Map) return;

      final messageId = data["messageId"]?.toString();
      if (messageId == null) return;

      final deliveredAt = data["deliveredAt"]?.toString();
      final readAt = data["readAt"]?.toString();

      for (int i = 0; i < messages.length; i++) {
        if (messages[i].id == messageId) {
          messages[i] = ChatMessage(
            id: messages[i].id,
            threadId: messages[i].threadId,
            fromType: messages[i].fromType,
            fromId: messages[i].fromId,
            text: messages[i].text,
            timestamp: messages[i].timestamp,
            deliveredAt: deliveredAt,
            readAt: readAt,
            isExchangeRequest: messages[i].isExchangeRequest,
            exchangeData: messages[i].exchangeData,
          );
          break;
        }
      }
      notifyListeners();
    });

    // ------- status bulk -------
    socket.on("chat:status_bulk", (data) {
      if (data is! Map) return;

      final List<dynamic> messageIds = data["messageIds"] ?? [];
      final readAt = data["readAt"]?.toString();
      if (messageIds.isEmpty || readAt == null) return;

      for (int i = 0; i < messages.length; i++) {
        if (messageIds.contains(messages[i].id)) {
          messages[i] = ChatMessage(
            id: messages[i].id,
            threadId: messages[i].threadId,
            fromType: messages[i].fromType,
            fromId: messages[i].fromId,
            text: messages[i].text,
            timestamp: messages[i].timestamp,
            deliveredAt: messages[i].deliveredAt ?? readAt,
            readAt: readAt,
            isExchangeRequest: messages[i].isExchangeRequest,
            exchangeData: messages[i].exchangeData,
          );
        }
      }
      notifyListeners();
    });
  }

  // =========================
  // Delivered / Read
  // =========================
  void _markMessagesAsDelivered() {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    final ids = messages
        .where((m) => m.fromType != "seller" && m.deliveredAt == null && m.id != null)
        .map((m) => m.id!)
        .toList();

    for (final id in ids) {
      socket.emit("chat:delivered", {"messageId": id});
    }
  }

  void _markSingleMessageDelivered(String messageId) {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;
    socket.emit("chat:delivered", {"messageId": messageId});
  }

  void _markMessagesAsRead() {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    final ids = messages
        .where((m) => m.fromType != "seller" && m.readAt == null && m.id != null)
        .map((m) => m.id!)
        .toList();

    if (ids.isNotEmpty) {
      socket.emit("chat:read", {"threadId": threadId, "messageIds": ids});
    }
  }

  void _markSingleMessageRead(String messageId) {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;
    socket.emit("chat:read", {"threadId": threadId, "messageIds": [messageId]});
  }

  // =========================
  // Send (NO FRONTEND INSERT ✅)
  // =========================
  void sendMessage() {
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    final socket = SocketService().socket;
    if (socket == null || !socket.connected) {
      AppToast.error("Socket not connected");
      return;
    }

    final clientId = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ DO NOT insert temp message (front end se show nahi)
    msgController.clear();
    scrollToBottom();
    onTyping("");

    socket.emitWithAck(
      "chat:send",
      {
        "threadId": threadId,
        "toType": toType,
        "toId": toId,
        "text": text,
        "clientId": clientId,
      },
      ack: (resp) {
        // ✅ ack se insert/replace nahi karna, sirf log/error
        if (resp is Map && resp["ok"] != true) {
          AppToast.error(resp["message"]?.toString() ?? "Failed to send");
        }
        // success case: socket "chat:message" will come and show msg once
      },
    );
  }

  // =========================
  // Typing
  // =========================
  void onTyping(String value) {
    final socket = SocketService().socket;
    if (socket == null || !socket.connected) return;

    _typingTimer?.cancel();

    if (value.isNotEmpty) {
      if (_lastTypingValue != value) {
        socket.emit("chat:typing", {"threadId": threadId, "isTyping": true});
        _lastTypingValue = value;
      }

      _typingTimer = Timer(const Duration(seconds: 2), () {
        socket.emit("chat:typing", {"threadId": threadId, "isTyping": false});
        _lastTypingValue = null;
      });
    } else {
      socket.emit("chat:typing", {"threadId": threadId, "isTyping": false});
      _lastTypingValue = null;
    }
  }

  // =========================
  // Exchange decision (dialog stays UI)
  // =========================
  Future<void> handleExchangeDecision(
    BuildContext context,
    String exchangeId,
    String decision,
  ) async {
    if (isProcessing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          decision == "Accepted" ? "Accept Exchange?" : "Reject Exchange?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: decision == "Accepted" ? Colors.green : Colors.red,
          ),
        ),
        content: Text(
          decision == "Accepted"
              ? "Accept this exchange request? PDF will be generated."
              : "Reject this exchange request?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: decision == "Accepted" ? Colors.green : Colors.red,
            ),
            child: Text(decision),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isProcessing = true;
    notifyListeners();

    try {
      final repo = ExchangeDecisionRepository();

      final normalizedDecision = (decision == "Denied") ? "Rejected" : decision;

      final success = await repo.makeDecision(
        exchangeId: exchangeId,
        decision: decision,
        note: normalizedDecision == "Accepted"
            ? "Your exchange request has been approved."
            : "Cannot process this exchange request.",
      );

      if (!success) {
        AppToast.error("Failed to process");
        return;
      }

      for (int i = 0; i < messages.length; i++) {
        final m = messages[i];
        if (m.isExchangeRequest == true && m.exchangeData?.exchangeId == exchangeId) {
          messages[i] = ChatMessage(
            id: m.id,
            threadId: m.threadId,
            fromType: m.fromType,
            isExchangeRequest: true,
            timestamp: m.timestamp,
            text: m.text,
            deliveredAt: m.deliveredAt,
            readAt: m.readAt,
            exchangeData: ExchangeRequestData(
              exchangeId: m.exchangeData?.exchangeId,
              orderId: m.exchangeData?.orderId,
              productId: m.exchangeData?.productId,
              productName: m.exchangeData?.productName,
              reason: m.exchangeData?.reason,
              status: decision == "Denied" ? "Rejected" : "Accepted",
              createdAt: m.exchangeData?.createdAt,
              images: m.exchangeData?.images ?? const [],
            ),
          );
          break;
        }
      }
      notifyListeners();
    } catch (e) {
      AppToast.error("Error: $e");
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
