import 'package:flutter/material.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';

class BulkBookingResult {
  final String orderMongoId;
  final bool success;
  final String? trackNumber;
  final String? slipLink;
  final String? error;
  final bool alreadyBooked;

  BulkBookingResult({
    required this.orderMongoId,
    required this.success,
    this.trackNumber,
    this.slipLink,
    this.error,
    this.alreadyBooked = false,
  });

  factory BulkBookingResult.fromJson(Map<String, dynamic> json) {
    return BulkBookingResult(
      orderMongoId: json['orderMongoId'] ?? '',
      success: json['success'] == true,
      trackNumber: json['trackNumber'],
      slipLink: json['slipLink'],
      error: json['error'],
      alreadyBooked: json['alreadyBooked'] == true,
    );
  }
}

/// Books many Pending orders with Leopards in a single API call
/// (batchBookPacketsv2 on the backend) instead of one request per order.
///
/// The whole operation — the network call, updating [GetMyOrdersProvider],
/// and the completion toast — lives here rather than in OrderScreen's local
/// state. OrderScreen swaps out of the widget tree (and gets disposed)
/// whenever the seller switches bottom-nav tabs, since the shell renders
/// `screens[index]` directly instead of an IndexedStack — so anything tied
/// to that screen's State would silently stop reporting progress the
/// moment the seller navigates away mid-booking. This provider is
/// registered at the app root (see multiProvider.dart) and outlives any
/// single tab, so the booking keeps running — and still toasts when done —
/// no matter where the seller is by the time it finishes.
class BulkAcceptOrdersProvider with ChangeNotifier {
  final NetworkApiServices _api = NetworkApiServices();

  bool isProcessing = false;
  int totalCount = 0;
  int successCount = 0;
  int failedCount = 0;

  Future<void> runBulkAccept({
    required List<String> orderIds,
    required GetMyOrdersProvider ordersProvider,
  }) async {
    if (isProcessing || orderIds.isEmpty) return;

    isProcessing = true;
    totalCount = orderIds.length;
    successCount = 0;
    failedCount = 0;
    notifyListeners();

    try {
      final response = await _api.postApi(Global.BulkAcceptOrders, {
        'orderIds': orderIds,
      });

      final rawResults = response['results'];
      final results = rawResults is List
          ? rawResults
              .map((e) => BulkBookingResult.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <BulkBookingResult>[];

      final accountedFor = <String>{};
      for (final r in results) {
        accountedFor.add(r.orderMongoId);
        if (r.success) {
          successCount++;
          ordersProvider.updateOrderInList(
            r.orderMongoId,
            trackNumber: r.trackNumber,
            slipLink: r.slipLink,
          );
        } else {
          failedCount++;
        }
      }
      // Any requested id the backend didn't return a result for.
      failedCount += orderIds.where((id) => !accountedFor.contains(id)).length;

      if (successCount > 0) {
        AppToast.success("$successCount order(s) booked with Leopards");
      }
      if (failedCount > 0) {
        AppToast.error("$failedCount order(s) failed to book");
      }
    } catch (e) {
      failedCount = orderIds.length;
      AppToast.error("Bulk Leopards booking failed: $e");
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
