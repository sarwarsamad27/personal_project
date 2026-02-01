import 'package:flutter/material.dart';
import 'package:new_brand/models/chatThread/chatThread_model.dart';
import 'package:new_brand/viewModel/repository/chatThread/chatThread_repository.dart';

class CompanyChatThreadsProvider extends ChangeNotifier {
  final CompanyChatRepository repository = CompanyChatRepository();

  bool loading = false;
  ChatThreadListModel? threadListModel;

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

  /// ✅ Unread total count for badge
  int get unreadTotal {
    final threads = threadListModel?.threads ?? const [];
    int total = 0;

    for (final t in threads) {
      // ⚠️ apne model field ke hisaab se yahan adjust:
      // e.g: t.unreadCount / t.unreadMessages / t.unread
      final c = (t.unreadCount ?? 0); // <-- if field name different, change here
      total += c;
    }
    return total;
  }
}
