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

double get currentBalance  => walletData?.currentBalance  ?? 0.0;
double get totalDelivered  => walletData?.totalDelivered  ?? 0.0;
double get totalWithdrawn  => walletData?.totalWithdrawn  ?? 0.0;
double get totalDeposited  => walletData?.totalDeposited  ?? 0.0;
double get pendingBalance  => walletData?.pendingBalance  ?? 0.0;
double get pendingDueAmount => walletData?.pendingDueAmount ?? 0.0;
bool get isOrderBlocked    => walletData?.isOrderBlocked   ?? false;

  // ================= SEND OTP =================
  Future<bool> sendWithdrawCode({
    required String name,
    required String phone,
    required String amount,
    required String method,
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
        token: token ?? '',
      );

      return res.message == "Verification code sent";
    } catch (e) {
      debugPrint("Send OTP Error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= VERIFY OTP =================
  Future<bool> verifyWithdrawCode({
    required String code,
    required BuildContext context,
  }) async {
    final token = await LocalStorage.getToken();
    try {
      isLoading = true;
      notifyListeners();

      final res = await _verifyCode.verifyCode(otp: code, token: token ?? '');

      if (res.message == "Withdrawal request submitted") {
        /// 🔥 refresh wallet balance
        await fetchCompanyWallet();

        /// 🔥 refresh transaction history
        await context.read<TransactionHistoryProvider>().fetchTransactions();

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
              context.read<TransactionHistoryProvider>().fetchTransactions();
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
}
