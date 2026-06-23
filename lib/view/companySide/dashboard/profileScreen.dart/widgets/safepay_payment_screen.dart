import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getCompanyAmount_provider.dart';
import 'package:provider/provider.dart';

/// Shows the Safepay hosted-checkout page while polling the backend for the
/// webhook-confirmed payment status. The wallet is only ever credited
/// server-side once Safepay's webhook confirms the payment — this screen
/// just watches for that to have happened.
class SafepayPaymentScreen extends StatefulWidget {
  final double amount;
  final String checkoutUrl;
  final String trackId;
  final VoidCallback onPaymentDone;

  const SafepayPaymentScreen({
    super.key,
    required this.amount,
    required this.checkoutUrl,
    required this.trackId,
    required this.onPaymentDone,
  });

  @override
  State<SafepayPaymentScreen> createState() => _SafepayPaymentScreenState();
}

class _SafepayPaymentScreenState extends State<SafepayPaymentScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _verifying = false;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          // Safepay redirects here once the checkout flow ends. We never
          // need this page's actual content (the webhook is the source of
          // truth for whether the payment succeeded) — only the fact that a
          // redirect happened, so we check status immediately instead of
          // waiting for the next poll tick. Intercepting this also avoids
          // the WebView failing to load a plain-http page on some Android
          // setups (ERR_CLEARTEXT_NOT_PERMITTED).
          onNavigationRequest: (request) {
            final path = Uri.tryParse(request.url)?.path ?? '';
            if (path.contains('/safepay/success') ||
                path.contains('/safepay/cancel')) {
              _checkStatusNow();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _enableThirdPartyCookies();
    _controller.loadRequest(Uri.parse(widget.checkoutUrl));

    _startPolling();
  }

  // Android WebView blocks third-party cookies by default. Safepay's 3D
  // Secure step (Cardinal Commerce device fingerprinting + step-up iframe)
  // is hosted on a different domain and relies on them to signal back to
  // the parent page — without this, the checkout silently hangs at
  // "Transaction submitted" and never proceeds to success/failure.
  Future<void> _enableThirdPartyCookies() async {
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      final cookieManager = WebViewCookieManager();
      if (cookieManager.platform is AndroidWebViewCookieManager) {
        await (cookieManager.platform as AndroidWebViewCookieManager)
            .setAcceptThirdPartyCookies(platform, true);
      }
    }
  }

  Future<void> _checkStatusNow() async {
    if (_resolved || !mounted) return;
    final provider = context.read<CompanyWalletProvider>();
    final res = await provider.pollSafepayStatus(
      trackId: widget.trackId,
      context: context,
      maxAttempts: 1,
    );
    if (!mounted || res['status'] == 'pending') return;
    await _finish(res);
  }

  Future<void> _startPolling() async {
    final provider = context.read<CompanyWalletProvider>();
    final res = await provider.pollSafepayStatus(
      trackId: widget.trackId,
      context: context,
    );
    if (!mounted) return;

    if (res['status'] == 'pending') {
      // Timed out without a terminal result — leave the user here; the
      // webhook may still land and credit the wallet shortly after.
      return;
    }

    await _finish(res);
  }

  Future<void> _finish(Map<String, dynamic> res) async {
    if (_resolved || !mounted) return;
    _resolved = true;
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (res['status'] == 'success') {
      widget.onPaymentDone();
      AppToast.success(
        'Rs ${widget.amount.toStringAsFixed(0)} added to your wallet successfully!',
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      AppToast.show(res['message']?.toString() ?? 'Payment could not be confirmed.');
      setState(() {
        _verifying = false;
        _resolved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Rs ${widget.amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_verifying)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16.h),
                    Text('Confirming payment…',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
