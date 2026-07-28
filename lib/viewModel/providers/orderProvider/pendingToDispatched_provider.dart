import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/pendingToDispatched_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/orderProvider/order_provider.dart';
import 'package:new_brand/viewModel/repository/orderRepository/pendingToDispatched_repository.dart';

class PendingToDispatchedProvider extends ChangeNotifier {
  final PendingToDispatchedRepository repository =
      PendingToDispatchedRepository();


  bool loading = false;
  PendingToDispatchedModel? response;

  // ── Bulk plain status-dispatch (no courier booking) ──
  bool isBulkProcessing = false;

  Future<bool> updateOrderStatus({required String orderId , required String status}) async {
    final token = await LocalStorage.getToken();
    loading = true;
    notifyListeners();

    try {
      response = await repository.pendingToDispatched(
        orderId: orderId,
        token: token ?? '', status: status,
      );

      loading = false;
      notifyListeners();

      if (response?.message != null) {
        return true; // success
      }
    } catch (e) {
      loading = false;
      notifyListeners();
    }

    return false;
  }

  /// Marks many Pending orders as Dispatched in one go, without any courier
  /// booking — for sellers handling their own delivery/pickup. Lives here
  /// (not in OrderScreen's local state) so it keeps running — and still
  /// toasts on completion — even if the seller switches bottom-nav tabs
  /// mid-operation, which fully disposes OrderScreen (see
  /// BulkAcceptOrdersProvider for the same reasoning).
  Future<void> runBulkDispatch({
    required List<String> orderIds,
    required GetMyOrdersProvider ordersProvider,
  }) async {
    if (isBulkProcessing || orderIds.isEmpty) return;

    isBulkProcessing = true;
    notifyListeners();

    final token = await LocalStorage.getToken();
    int success = 0;
    int failed = 0;

    for (final orderId in orderIds) {
      try {
        final result = await repository.pendingToDispatched(
          orderId: orderId,
          token: token ?? '',
          status: "dispatched",
        );
        if (result.message != null) {
          success++;
          ordersProvider.updateOrderInList(orderId, status: "Dispatched");
        } else {
          failed++;
        }
      } catch (_) {
        failed++;
      }
    }

    isBulkProcessing = false;
    notifyListeners();

    if (success > 0) AppToast.success("$success order(s) dispatched");
    if (failed > 0) AppToast.error("$failed order(s) failed to dispatch");
  }
}

