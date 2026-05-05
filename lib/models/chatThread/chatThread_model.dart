// models/chatModel/chat_thread_model.dart

class ChatThreadModel {
  final String threadId;
  final String toType;
  final String toId;
  final String title;
  final String? image;
  final String lastMessage;
  final String lastMessageTime;
  final bool isExchangeRequest;
  final int unreadCount;

  ChatThreadModel({
    required this.threadId,
    required this.toType,
    required this.toId,
    required this.title,
    this.image,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isExchangeRequest = false,
    this.unreadCount = 0,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    return ChatThreadModel(
      threadId: json["threadId"] ?? "",
      toType: json["toType"] ?? "buyer",
      toId: json["toId"] ?? "",
      title: json["title"] ?? "Chat",
      image: json["image"],
      lastMessage: json["lastMessage"] ?? "",
      lastMessageTime: json["lastMessageTime"] ?? "",
      isExchangeRequest: json["isExchangeRequest"] ?? false,
      unreadCount: json["unreadCount"] ?? 0,
    );
  }

  ChatThreadModel copyWith({
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isExchangeRequest,
  }) {
    return ChatThreadModel(
      threadId: threadId,
      toType: toType,
      toId: toId,
      title: title,
      image: image,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isExchangeRequest: isExchangeRequest ?? this.isExchangeRequest,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ChatThreadListModel {
  final bool success;
  final String message;
  final List<ChatThreadModel> threads;

  ChatThreadListModel({
    required this.success,
    required this.message,
    required this.threads,
  });

  factory ChatThreadListModel.fromJson(Map<String, dynamic> json) {
    final threadsList = (json["threads"] as List?) ?? [];
    return ChatThreadListModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      threads: threadsList.map((e) => ChatThreadModel.fromJson(e)).toList(),
    );
  }
}