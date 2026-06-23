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
}
