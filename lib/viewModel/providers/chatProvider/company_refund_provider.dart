import 'package:flutter/material.dart';
import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/viewModel/repository/chatThread/companyRefund_repository.dart';

class CompanyRefundProvider extends ChangeNotifier {
  final CompanyRefundRepository _repo = CompanyRefundRepository();

  bool loading = false;
  bool processing = false;
  String? errorMessage;

  RefundRequestListModel? listModel;
  String? _currentFilter;

  List<ExchangeRequest> get requests => listModel?.requests ?? [];

  // ── Fetch ──────────────────────────────────────────────────────
  Future<void> fetchRequests({String? status}) async {
    _currentFilter = status;
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      listModel = await _repo.listRequests(status: status);
    } catch (e) {
      errorMessage = "Failed: $e";
    }
    loading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchRequests(status: _currentFilter);

  // ── Accept / Reject ────────────────────────────────────────────
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
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Mark received ──────────────────────────────────────────────
  Future<bool> markReceived(String refundId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.markReceived(refundId);
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Start inspection ───────────────────────────────────────────
  Future<bool> startInspection(String refundId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.startInspection(refundId);
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Inspection result ──────────────────────────────────────────
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
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Finalize refund ────────────────────────────────────────────
  Future<bool> finalizeRefund(String refundId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.finalizeRefund(refundId);
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }
}