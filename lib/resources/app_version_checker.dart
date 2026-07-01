import 'package:flutter/material.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';

/// Hits the backend's stored "latest version" for the seller app and shows
/// an update prompt if it doesn't match the version this build was shipped
/// with. Silent on any failure — this is a startup nicety, not something
/// that should ever block or error out the app.
Future<void> checkAppVersion(BuildContext context) async {
  try {
    final response = await NetworkApiServices().getApi(Global.AppVersionCheck);
    final latestVersion = response['latestVersion']?.toString();
    if (latestVersion == null || latestVersion == Global.currentAppVersion) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(
          'A new version of the Shookoo Seller app ($latestVersion) is available. '
          'Please update to keep using the latest features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColor.primaryColor)),
          ),
        ],
      ),
    );
  } catch (_) {
    // Never let a version-check failure affect normal app usage.
  }
}
