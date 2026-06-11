import 'package:flutter/material.dart';
import 'package:new_brand/viewModel/repository/aiAssistantRepository/AiAssistant_repository.dart';

enum AiChatRole { user, assistant }

class AiChatMessage {
  final AiChatRole role;
  final String text;
  final bool policyViolation;
  final bool isError;

  const AiChatMessage({
    required this.role,
    required this.text,
    this.policyViolation = false,
    this.isError = false,
  });
}

class AiAssistantProvider with ChangeNotifier {
  final AiAssistantRepository _repository = AiAssistantRepository();

  final List<AiChatMessage> messages = [];
  bool isSending = false;

  Future<void> sendMessage({
    required String token,
    required String text,
  }) async {
    final history = messages
        .where((m) => !m.isError)
        .map(
          (m) => {
            'role': m.role == AiChatRole.user ? 'user' : 'assistant',
            'content': m.text,
          },
        )
        .toList();

    messages.add(AiChatMessage(role: AiChatRole.user, text: text));
    isSending = true;
    notifyListeners();

    final result = await _repository.sendMessage(
      token: token,
      message: text,
      history: history,
    );

    isSending = false;

    final reply = result.reply?.trim();
    if (reply != null && reply.isNotEmpty) {
      messages.add(
        AiChatMessage(
          role: AiChatRole.assistant,
          text: reply,
          policyViolation: result.policyViolation,
        ),
      );
    } else {
      messages.add(
        AiChatMessage(
          role: AiChatRole.assistant,
          text:
              result.message ??
              "Sorry, I couldn't process that. Please try again.",
          isError: true,
        ),
      );
    }
    notifyListeners();
  }
}
