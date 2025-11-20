import 'package:flutter/material.dart';
import 'package:new_brand/models/auth/verifyCode_model.dart';
import 'package:new_brand/viewModel/repository/authRepository/verifyCode_repository.dart';

class VerifyCodeProvider with ChangeNotifier {
   final VerifyCodeRepository  repository = VerifyCodeRepository ();


  bool loading = false;
  VerifyCodeModel? verifyData;
  String? errorMessage;

 Future<void> verifyCode({
  required String email,
  required String verificationCode,
}) async {
  loading = true;
  notifyListeners();

  try {
    final response = await repository.verifyCode(email, verificationCode);
    verifyData = response;
    errorMessage = null;
  } catch (e) {
    verifyData = null;
    errorMessage = e.toString().replaceAll('Exception: ', '');
  } finally {
    loading = false;
    notifyListeners();
  }
}
}
