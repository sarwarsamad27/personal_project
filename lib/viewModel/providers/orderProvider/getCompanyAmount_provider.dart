import 'package:flutter/material.dart';
import 'package:new_brand/models/orders/getCompanyAmount_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/orderRepository/getCompanyAmount_repository.dart';
import 'package:new_brand/viewModel/repository/orderRepository/paymentRepository/paymentRequest_repository.dart';
import 'package:new_brand/models/orders/payment/paymentRequest_model.dart';

import '../../repository/orderRepository/paymentRepository/verifyCode_repository.dart';

class CompanyWalletProvider with ChangeNotifier {
  final GetCompanyAmountRepository _walletRepo = GetCompanyAmountRepository();
  final PaymentRequestRepository _paymentRepo = PaymentRequestRepository();
  final VerifyCodeRepository _verifyCode = VerifyCodeRepository();

  bool isLoading = false;
  bool codeSent = false;

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

  double get currentBalance => (walletData?.currentBalance ?? 0).toDouble();

  // ================= SEND CODE =================
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

      isLoading = false;
      notifyListeners();

      if (res.message == "Verification code sent") {
        codeSent = true;
        return true;
      }
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ================= VERIFY CODE =================
  Future<bool> verifyWithdrawCode({required String code}) async {
    final token = await LocalStorage.getToken();
    try {
      isLoading = true;
      notifyListeners();

      final res = await _verifyCode.verifyCode(otp: code, token: token ?? '');
      isLoading = false;
      notifyListeners();

      return res.message == "Withdrawal request submitted";
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
