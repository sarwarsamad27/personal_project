  // viewModel/repository/chatRepository/company_chat_repository.dart

  import 'package:new_brand/models/chatThread/chatThread_model.dart';
  import 'package:new_brand/network/network_api_services.dart';
  import 'package:new_brand/resources/global.dart';
  import 'package:flutter/foundation.dart';

  class CompanyChatRepository {
    final NetworkApiServices apiServices = NetworkApiServices();

    Future<ChatThreadListModel> getChatThreads() async {
      try {
        debugPrint("📩 Fetching company chat threads");

        final response = await apiServices.getApi(Global.companyChatThreads);

        debugPrint("✅ Company chat threads response: $response");

        return ChatThreadListModel.fromJson(response);
      } catch (e) {
        debugPrint("❌ Error fetching company chat threads: $e");
        return ChatThreadListModel(
          success: false,
          message: "Error: $e",
          threads: [],
        );
      }
    }
  }
