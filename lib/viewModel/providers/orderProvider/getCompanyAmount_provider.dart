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

  // ================= JAZZCASH CREDIT (INITIATE) =================
  Future<Map<String, dynamic>?> initiateJazzcashCredit({
    required String phone,
    required String amount,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _addMoneyRepo.initiateJazzcashCredit(
        phone: phone,
        amount: amount,
      );

      // ✅ txnRefNo aaya matlab success
      if (res['txnRefNo'] != null) {
        return res;
      }
      return null;
    } catch (e) {
      debugPrint("JazzCash Initiate Error: $e");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= JAZZCASH CREDIT (CONFIRM/INQUIRE) =================
  Future<bool> confirmJazzcashCredit({
    required String txnRefNo,
    required BuildContext context,
    required String otp,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _addMoneyRepo.confirmJazzcashCredit(
        txnRefNo: txnRefNo,
        otp: otp,
      );

      if (res['message'] == "Wallet credited successfully") {
        /// 🔥 refresh wallet balance
        await fetchCompanyWallet();

        /// 🔥 refresh transaction history
        if (context.mounted) {
          await context.read<TransactionHistoryProvider>().fetchTransactions();
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("JazzCash Confirm Error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
