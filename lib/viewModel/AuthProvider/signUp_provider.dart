import 'package:flutter/material.dart';
import 'package:new_brand/models/auth/signUp_model.dart';
import 'package:new_brand/viewModel/repository/authRepository/signUp_repository.dart';

class SignUpProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SignUpModel? _signUpData;
  SignUpModel? get signUpData => _signUpData;

  final SignUpRepository repository = SignUpRepository();
 

  Future<void> signUpProvider({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

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
      _errorMessage = "Password must be at least 6 characters long";
      _loading = false;
      notifyListeners();
      return;
    }

    if (confirmPassword.isEmpty) {
      _errorMessage = "Confirm Password is required";
      _loading = false;
      notifyListeners();
      return;
    }

    if (password != confirmPassword) {
      _errorMessage = "Passwords do not match";
      _loading = false;
      notifyListeners();
      return;
    }

    // If validation passes, make the API call
    _signUpData = await repository.signUp(email, password);

    _loading = false;
    notifyListeners();

    if (_signUpData?.newUser == null) {
      _errorMessage = _signUpData?.message ?? "Signup failed";
      notifyListeners();
    }
  }
}
