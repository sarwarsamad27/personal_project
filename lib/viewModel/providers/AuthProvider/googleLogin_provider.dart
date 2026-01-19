import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_brand/models/auth/googleLogin_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/authRepository/login_repository.dart';

class CompanyGoogleLoginProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  GoogleLoginModel? _loginData;
  GoogleLoginModel? get loginData => _loginData;

  final LoginRepository repository = LoginRepository();

  // ✅ WEB Client ID (Google Console → Credentials → OAuth Web)
  static const String _webClientId =
      '1029779159303-q7l67jmdltqqhen5ahll09bjv0i2kv3k.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  CompanyGoogleLoginProvider() {
    _googleSignIn = GoogleSignIn(
      scopes: const ['email'],
      serverClientId: _webClientId, // ✅ important for idToken
    );
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Future<void> loginWithGoogle() async {
    _errorMessage = null;
    _loginData = null;
    _setLoading(true);

    try {
      await _googleSignIn.signOut();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        _errorMessage = "Google sign-in cancelled";
        _setLoading(false);
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      if (kDebugMode) {
        debugPrint("Google account: ${account.email}");
        debugPrint("Has idToken: ${auth.idToken != null}");
      }

      final String? idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _errorMessage =
            "Google idToken not found. Check WEB clientId + SHA-1 config.";
        _setLoading(false);
        return;
      }

      // ✅ MUST return LoginModel (fix repository below)
      final GoogleLoginModel response = await repository.googleLogin(idToken);
      _loginData = response;

      final token = response.token;
      if (token != null && token.isNotEmpty) {
        await LocalStorage.saveToken(token);
      } else {
        _errorMessage = response.message ?? "Google login failed";
      }

      _setLoading(false);
    } catch (e) {
      _errorMessage = "Google login error: $e";
      _setLoading(false);
    }
  }
}
