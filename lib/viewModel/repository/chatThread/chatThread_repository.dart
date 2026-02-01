  // viewModel/repository/chatRepository/company_chat_repository.dart

  import 'package:new_brand/models/chatThread/chatThread_model.dart';
  import 'package:new_brand/network/network_api_services.dart';
  import 'package:new_brand/resources/global.dart';

  class CompanyChatRepository {
    final NetworkApiServices apiServices = NetworkApiServices();

    Future<ChatThreadListModel> getChatThreads() async {
      try {
        print("📩 Fetching company chat threads");

        final response = await apiServices.getApi(Global.companyChatThreads);

        print("✅ Company chat threads response: $response");

        return ChatThreadListModel.fromJson(response);
      } catch (e) {
        print("❌ Error fetching company chat threads: $e");
        return ChatThreadListModel(
          success: false,
          message: "Error: $e",
          threads: [],
        );
      }
    }
  }