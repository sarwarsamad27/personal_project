import 'package:flutter/material.dart';
import 'package:new_brand/models/chatThread/chatThread_model.dart';
import 'package:new_brand/viewModel/repository/chatThread/chatThread_repository.dart';

class CompanyChatThreadsProvider extends ChangeNotifier {
  final CompanyChatRepository repository = CompanyChatRepository();

  bool loading = false;
  ChatThreadListModel? threadListModel;

  List<ChatThreadModel> get threads => threadListModel?.threads ?? const [];

  // ── Fetch from API (only on initial load or manual refresh) ──────────────
  Future<void> fetchThreads() async {
    loading = true;
    notifyListeners();
    try {
      threadListModel = await repository.getChatThreads();
    } catch (e) {
      threadListModel = ChatThreadListModel(
        success: false,
        message: "Error: $e",
        threads: [],
      );
    }
    loading = false;
    notifyListeners();
  }

  // ── Update a thread in-place when a socket message arrives ───────────────
  // No API call — purely in-memory.
  void onNewMessage({
    required String threadId,
    required String lastMessage,
    required String lastMessageTime,
    bool incrementUnread = true,
    bool isExchangeRequest = false,
  }) {
    final list = threadListModel?.threads;
    if (list == null) {
      // No data yet — schedule a fetch
      fetchThreads();
      return;
    }

    final idx = list.indexWhere((t) => t.threadId == threadId);
    if (idx == -1) {
      // Unknown thread (first message from a new buyer) — fetch to discover it
      fetchThreads();
      return;
    }

    final updated = list[idx].copyWith(
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: incrementUnread ? list[idx].unreadCount + 1 : list[idx].unreadCount,
      isExchangeRequest: isExchangeRequest,
    );

    // Rebuild list: updated thread goes to the top
    final newList = List<ChatThreadModel>.from(list);
    newList.removeAt(idx);
    newList.insert(0, updated);

    threadListModel = ChatThreadListModel(
      success: threadListModel!.success,
      message: threadListModel!.message,
      threads: newList,
    );
    notifyListeners();
  }

  // ── Reset unread count when user opens a thread ──────────────────────────
  void markThreadRead(String threadId) {
    final list = threadListModel?.threads;
    if (list == null) return;

    final idx = list.indexWhere((t) => t.threadId == threadId);
    if (idx == -1 || list[idx].unreadCount == 0) return;

    final newList = List<ChatThreadModel>.from(list);
    newList[idx] = list[idx].copyWith(unreadCount: 0);

    threadListModel = ChatThreadListModel(
      success: threadListModel!.success,
      message: threadListModel!.message,
      threads: newList,
    );
    notifyListeners();
  }

  // ── Total unread badge count ─────────────────────────────────────────────
  int get unreadTotal {
    int total = 0;
    for (final t in threads) {
      total += t.unreadCount;
    }
    return total;
  }
}
