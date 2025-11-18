import 'package:flutter/material.dart';
import 'package:new_brand/models/auth/login_model.dart';
import 'package:new_brand/viewModel/repository/authRepository/login_repository.dart';

class LoginProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginModel? _loginData;
  LoginModel? get loginData => _loginData;

  final LoginRepository repository = LoginRepository();

  Future<void> loginProvider({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    // VALIDATIONS
    if (email.isEmpty) {
      _errorMessage = "Email is required";
      _loading = false;
      notifyListeners();
      return;
    }

    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      _errorMessage = "Invalid email format";
      _loading = false;
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      _errorMessage = "Password is required";
      _loading = false;
      notifyListeners();
      return;
    }

    if (password.length < 6) {
      _errorMessage = "Password must be at least 6 characters";
      _loading = false;
      notifyListeners();
      return;
    }

    // API CALL
    _loginData = await repository.login(email, password);

    _loading = false;
    notifyListeners();

    // API ERROR HANDLING
    if (_loginData?.token == null) {
      _errorMessage = _loginData?.message ?? "Login failed";
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
