// viewModel/providers/exchangeProvider/company_exchange_provider.dart

import 'package:flutter/material.dart';
import 'package:new_brand/models/chatThread/exchangeRequestModel.dart';
import 'package:new_brand/viewModel/repository/chatThread/CompanyExchange_repository.dart';

class CompanyExchangeProvider extends ChangeNotifier {
  final CompanyExchangeRepository _repo = CompanyExchangeRepository();

  bool loading = false;
  bool processing = false;
  String? errorMessage;

  ExchangeRequestListModel? listModel;
  String? _currentFilter; // null = all

  List<ExchangeRequest> get requests => listModel?.requests ?? [];

  // ── Fetch list ─────────────────────────────────────────────────
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

  // ── Accept / Deny ──────────────────────────────────────────────
  Future<bool> decide({
    required String exchangeId,
    required String decision,
    required String resolutionType,
    String note = "",
  }) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.decide(
      exchangeId: exchangeId,
      decision: decision,
      resolutionType: resolutionType,
      note: note,
    );
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Mark received ──────────────────────────────────────────────
  Future<bool> markReceived(String exchangeId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.markReceived(exchangeId);
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Start inspection ───────────────────────────────────────────
  Future<bool> startInspection(String exchangeId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.startInspection(exchangeId);
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Inspection result ──────────────────────────────────────────
  Future<bool> submitInspectionResult({
    required String exchangeId,
    required String result,
    required String note,
  }) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.submitInspectionResult(
      exchangeId: exchangeId,
      result: result,
      note: note,
    );
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Ship replacement ───────────────────────────────────────────
  Future<bool> shipReplacement({
    required String exchangeId,
    required String trackingNumber,
    required String courierName,
  }) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.shipReplacement(
      exchangeId: exchangeId,
      trackingNumber: trackingNumber,
      courierName: courierName,
    );
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Process refund ─────────────────────────────────────────────
  Future<bool> processRefund({
    required String exchangeId,
    required double amount,
  }) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.processRefund(
      exchangeId: exchangeId,
      refundAmount: amount,
    );
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }

  // ── Mark completed ─────────────────────────────────────────────
  Future<bool> markCompleted(String exchangeId) async {
    processing = true;
    notifyListeners();
    final ok = await _repo.markCompleted(exchangeId);
    if (ok) await refresh();
    processing = false;
    notifyListeners();
    return ok;
  }
}