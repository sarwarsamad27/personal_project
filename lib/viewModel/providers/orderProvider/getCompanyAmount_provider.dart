import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getCompanyAmount_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/providers/orderProvider/transactionHIstory_provider.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getCompanyAmount_repository.dart';
import 'package:new_brand/viewModel/repository/orderRepository/paymentRepository/paymentRequest_repository.dart';
import 'package:new_brand/models/orders/payment/paymentRequest_model.dart';
import 'package:provider/provider.dart';
import '../../repository/orderRepository/paymentRepository/verifyCode_repository.dart';
import '../../repository/orderRepository/paymentRepository/addMoney_repository.dart';

class CompanyWalletProvider with ChangeNotifier {
  final GetCompanyAmountRepository _walletRepo = GetCompanyAmountRepository();
  final PaymentRequestRepository _paymentRepo = PaymentRequestRepository();
  final VerifyCodeRepository _verifyCode = VerifyCodeRepository();
  final AddMoneyRepository _addMoneyRepo = AddMoneyRepository();

  bool isLoading = false;

  GetCompanyAmountModel? walletData;

  // Set by sendWithdrawCode() — the E.164 phone number the backend sent the
  // OTP to, kept around for display/reference during the verify step.
  String? pendingWithdrawPhone;

  // Set by sendWithdrawCode() on failure — the backend's raw message (e.g.
  // a bad mobile-number format), suppressed as a global toast so the caller
  // can decide how to surface it (inline under a field, etc).
  String? lastSendCodeError;

  // trackIds whose checkout screen was closed before the poll resolved —
  // without this, the loop below keeps hitting the backend every few
  // seconds for up to ~2 minutes after the user has already left the screen.
  final Set<String> _cancelledTrackIds = {};

  void cancelPolling(String trackId) => _cancelledTrackIds.add(trackId);

  // ================= FETCH WALLET =================
  Future<void> fetchCompanyWallet() async {
    try {
      isLoading = true;
      notifyListeners();

      walletData = await _walletRepo.getCompanyAmount();
    } catch (e) {
      debugPrint("Wallet Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get currentBalance => walletData?.currentBalance ?? 0.0;
  double get totalDelivered => walletData?.totalDelivered ?? 0.0;
  double get totalWithdrawn => walletData?.totalWithdrawn ?? 0.0;
  double get totalDeposited => walletData?.totalDeposited ?? 0.0;
  double get pendingBalance => walletData?.pendingBalance ?? 0.0;
  double get pendingDueAmount => walletData?.pendingDueAmount ?? 0.0;
  bool get isOrderBlocked => walletData?.isOrderBlocked ?? false;

  // ================= SEND OTP =================
  Future<bool> sendWithdrawCode({
    required String name,
    required String phone,
    required String amount,
    required String method,
    String? bankName,
    String? accountNumber,
    String? iban,
  }) async {
    final token = await LocalStorage.getToken();
    try {
      isLoading = true;
      notifyListeners();

      final PaymentRequestModel res = await _paymentRepo.paymentRequest(
        name: name,
        phone: phone,
        amount: amount,
        method: method,
        bankName: bankName,
        accountNumber: accountNumber,
        iban: iban,
        token: token ?? '',
      );

      final ok = res.message == "Verification code sent via SMS";
      if (ok) {
        pendingWithdrawPhone = res.phone;
        lastSendCodeError = null;
      } else {
        lastSendCodeError = res.message;
      }
      return ok;
    } catch (e) {
      debugPrint("Send OTP Error: $e");
      lastSendCodeError = null;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= VERIFY OTP =================
  // 💤 Firebase ID token version (restore when Blaze is enabled): change
  // `code` -> `idToken` here and in verifyCode_repository.dart's verifyCode().
  Future<bool> verifyWithdrawCode({
    required String code,
    required BuildContext context,
  }) async {
    final token = await LocalStorage.getToken();
    try {
      isLoading = true;
      notifyListeners();

      final res = await _verifyCode.verifyCode(
        otp: code,
        token: token ?? '',
      );

      if (res.message == "Withdrawal request submitted") {
        /// 🔥 refresh wallet balance
        await fetchCompanyWallet();

        /// 🔥 refresh transaction history — best-effort only. The backend
        /// has already confirmed the withdrawal itself; a failure here
        /// (e.g. a stale/unmounted context) must never flip a genuinely
        /// successful verification back to "failed" and leave the caller's
        /// bottom sheet stuck open.
        try {
          await context.read<TransactionHistoryProvider>().fetchTransactions(
            refresh: true,
          );
        } catch (e) {
          debugPrint("Post-withdraw transaction refresh failed: $e");
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Verify OTP Error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= SAFEPAY: CREATE CHECKOUT =================
  /// Returns `{url, trackId}` on success, null on failure.
  Future<Map<String, dynamic>?> initSafepayCheckout({
    required String amount,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _addMoneyRepo.initSafepayCheckout(amount: amount);

      if (res['url'] != null && res['trackId'] != null) {
        return res;
      }
      return null;
    } catch (e) {
      debugPrint("Safepay Checkout Error: $e");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= SAFEPAY: POLL STATUS =================
  /// Polls until the webhook-driven status is no longer "pending", or
  /// [maxAttempts] is reached. The wallet is only ever credited server-side
  /// — this just watches for that to have happened.
  Future<Map<String, dynamic>> pollSafepayStatus({
    required String trackId,
    BuildContext? context,
    Duration interval = const Duration(seconds: 3),
    int maxAttempts = 40, // ~2 minutes
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      if (_cancelledTrackIds.remove(trackId)) {
        return {'status': 'cancelled'};
      }
      final res = await _addMoneyRepo.getSafepayStatus(trackId: trackId);
      final status = res['status'];
      if (status != null && status != 'pending') {
        if (status == 'success') {
          await fetchCompanyWallet();
          try {
            if (context != null && context.mounted) {
              context.read<TransactionHistoryProvider>().fetchTransactions(
                refresh: true,
              );
            }
          } catch (_) {}
        }
        return res;
      }
      await Future.delayed(interval);
    }
    _cancelledTrackIds.remove(trackId);
    return {'status': 'pending', 'message': 'Payment confirmation timed out'};
  }

  // ================= MANUAL BANK TRANSFER: SUBMIT DEPOSIT REQUEST =====
  /// Unlike Safepay, nothing is credited here — this just files a pending
  /// request with a screenshot for admin to manually verify. Returns true
  /// if the request was accepted (status 200), regardless of what admin
  /// later decides.
  Future<bool> submitBankTransfer({
    required String amount,
    required String screenshotBase64,
    BuildContext? context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _addMoneyRepo.submitBankTransfer(
        amount: amount,
        screenshotBase64: screenshotBase64,
      );

      final ok = res['success'] == true;
      if (ok) {
        try {
          if (context != null && context.mounted) {
            context.read<TransactionHistoryProvider>().fetchTransactions(
              refresh: true,
            );
          }
        } catch (_) {}
      }
      return ok;
    } catch (e) {
      debugPrint("Bank Transfer Submit Error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
