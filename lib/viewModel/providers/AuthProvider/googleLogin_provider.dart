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
      '900853727644-a6m3k2sf0bdumpfkvm7h2hhlal4ct76i.apps.googleusercontent.com';

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
        if (kDebugMode) {
          debugPrint(
            "Google idToken not found. Check WEB clientId + SHA-1 config.",
          );
        }
        _errorMessage =
            "Something went wrong signing in with Google. Please try again.";
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
      if (kDebugMode) {
        debugPrint("Google login error (raw): $e");
      }
      _errorMessage = _friendlyGoogleError(e);
      _setLoading(false);
    }
  }

  /// Maps raw Google Sign-In exceptions to a clean, user-facing message.
  /// The technical detail (exception type, API error code) is only ever
  /// logged via debugPrint above — never shown to the end user.
  String _friendlyGoogleError(Object e) {
    final raw = e.toString();

    if (raw.contains('ApiException: 10') || raw.contains('sign_in_failed')) {
      // DEVELOPER_ERROR — almost always a SHA-1/config mismatch on our end,
      // not something the user can fix. Don't expose that detail to them.
      return "Google Sign-In isn't available right now. Please try again later or log in with email.";
    }
    if (raw.contains('network_error') ||
        raw.contains('SocketException') ||
        raw.contains('TimeoutException')) {
      return "Network error. Please check your internet connection and try again.";
    }
    if (raw.contains('sign_in_canceled') || raw.contains('sign_in_cancelled')) {
      return "Google sign-in cancelled";
    }
    return "Something went wrong signing in with Google. Please try again.";
  }
}
