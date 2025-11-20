import 'package:flutter/material.dart';
import 'package:new_brand/models/auth/forgotPassword_model.dart';
import 'package:new_brand/viewModel/repository/authRepository/forgotPassword_repository.dart';

class ForgotProvider with ChangeNotifier {
  final ForgotPasswordRepository repository = ForgotPasswordRepository();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ForgotPasswordModel? _forgotData;
  ForgotPasswordModel? get forgotData => _forgotData;

  Future<void> forgotPassword({required String email}) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.isEmpty) {
      _errorMessage = "Email is required";
      _loading = false;
      notifyListeners();
      return;
    }

    final response = await repository.forgotPassword(email);

    _loading = false;

    if (response != null && response.message != null) {
      _forgotData = response;
    } else {
      _errorMessage = "Something went wrong";
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
