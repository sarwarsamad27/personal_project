import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class AddMoneyRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  /// Creates a Safepay hosted-checkout session for topping up the seller
  /// wallet. Returns `{message, url, trackId}` on success.
  Future<Map<String, dynamic>> initSafepayCheckout({
    required String amount,
  }) async {
    final response = await apiServices.postApi(
      Global.SellerSafepayCheckout,
      {'amount': amount},
    );
    return response;
  }

  /// Polls the checkout status (the wallet is only ever credited server-side
  /// once Safepay's webhook confirms the payment). Returns
  /// `{status, amount, newBalance?}`.
  Future<Map<String, dynamic>> getSafepayStatus({
    required String trackId,
  }) async {
    final response = await apiServices.getApi(
      '${Global.SellerSafepayStatus}?trackId=$trackId',
    );
    return response;
  }

  /// Submits a manual bank-transfer deposit request — nothing is credited
  /// until an admin verifies the screenshot and approves it (see
  /// getCompanyWalletAmount_controller.js's sibling admin review flow).
  /// [screenshotBase64] is a `data:image/...;base64,...` data URI.
  Future<Map<String, dynamic>> submitBankTransfer({
    required String amount,
    required String screenshotBase64,
  }) async {
    final response = await apiServices.postApi(
      Global.SellerBankTransferSubmit,
      {'amount': amount, 'screenshot': screenshotBase64},
    );
    return response;
  }
}
