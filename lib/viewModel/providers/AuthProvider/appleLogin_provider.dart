// viewModel/providers/AuthProvider/appleLogin_provider.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:new_brand/models/auth/appleLogin_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/authRepository/login_repository.dart';

class CompanyAppleLoginProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppleLoginModel? _loginData;
  AppleLoginModel? get loginData => _loginData;

  final LoginRepository repository = LoginRepository();

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ nonce helpers (recommended)
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => charset[rand.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> loginWithApple() async {
    _errorMessage = null;
    _loginData = null;
    _setLoading(true);

    try {
      // ✅ check availability (iOS 13+ mostly true)
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        _errorMessage = "Apple Sign-In is not available on this device";
        _setLoading(false);
        return;
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        _errorMessage = "Apple identityToken not found";
        _setLoading(false);
        return;
      }

      // ✅ Full name only on first login
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((e) => (e ?? '').trim().isNotEmpty).join(' ').trim();

      if (kDebugMode) {
        debugPrint("Apple email: ${credential.email}"); // may be null
        debugPrint("Has identityToken: ${identityToken.isNotEmpty}");
      }

      final AppleLoginModel response = await repository.appleLogin(
        identityToken: identityToken,
        email: credential.email, // may be null after first time
        fullName: fullName.isEmpty ? null : fullName,
      );

      _loginData = response;

      final token = response.token;
      if (token != null && token.isNotEmpty) {
        await LocalStorage.saveToken(token);
      } else {
        _errorMessage = response.message ?? "Apple login failed";
      }

      _setLoading(false);
    } catch (e) {
      _errorMessage = "Apple login error: $e";
      _setLoading(false);
    }
  }
}
