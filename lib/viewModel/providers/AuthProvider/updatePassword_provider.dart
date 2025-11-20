import 'package:flutter/material.dart';
import 'package:new_brand/models/auth/updatePassword_model.dart';
import 'package:new_brand/viewModel/repository/authRepository/updatePassword_repository.dart';

class UpdatePasswordProvider extends ChangeNotifier {
  final UpdatePasswordRepository repository = UpdatePasswordRepository();

  UpdatePasswordModel? updateData;
  String? errorMessage;
  bool loading = false;

  Future<void> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    loading = true;
    errorMessage = null;
    updateData = null;
    notifyListeners();

    try {
      final result = await repository.updatePassword(
        email,
        newPassword,
      );
      updateData = result;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
