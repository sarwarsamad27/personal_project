import 'package:flutter/material.dart';
import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/viewModel/repository/chatThread/companyRefund_repository.dart';

class CompanyRefundProvider extends ChangeNotifier {
  final CompanyRefundRepository _repo = CompanyRefundRepository();

  bool loading = false;
  bool processing = false;
  String? errorMessage;

  List<ExchangeRequest> _all = [];
  bool hasFetched = false;

  // All requests — screen filters from this list client-side
  List<ExchangeRequest> get requests => _all;

  // ── Fetch ALL (no server filter) ───────────────────────────────
  Future<void> fetchRequests({String? status}) async {
    // Ignore status — always load everything, screen filters locally
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final model = await _repo.listRequests(status: null);
      _all = model.requests;
      hasFetched = true;
    } catch (e) {
      errorMessage = "Failed: $e";
    }
    loading = false;
    notifyListeners();
  }

  // Pull-to-refresh: re-fetch all
  Future<void> refresh() => fetchRequests();

  // ── Actions — update list in-place after success ───────────────

  Future<bool> decide({
    required String refundId,
    required String decision,
    String note = "",
  }) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.decide(
      refundId: refundId,
      decision: decision,
      note: note,
    );
    if (ok) await _refreshItem(refundId);
    processing = false;
    notifyListeners();
    return ok;
  }

  Future<bool> markReceived(String refundId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.markReceived(refundId);
    if (ok) await _refreshItem(refundId);
    processing = false;
    notifyListeners();
    return ok;
  }

  Future<bool> startInspection(String refundId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.startInspection(refundId);
    if (ok) await _refreshItem(refundId);
    processing = false;
    notifyListeners();
    return ok;
  }

  Future<bool> submitInspectionResult({
    required String refundId,
    required String result,
    required String note,
  }) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.submitInspectionResult(
      refundId: refundId,
      result: result,
      note: note,
    );
    if (ok) await _refreshItem(refundId);
    processing = false;
    notifyListeners();
    return ok;
  }

  Future<bool> finalizeRefund(String refundId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.finalizeRefund(refundId);
    if (ok) await _refreshItem(refundId);
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Refresh full list after an action ─────────────────────────
  Future<void> _refreshItem(String refundId) => fetchRequests();
}
