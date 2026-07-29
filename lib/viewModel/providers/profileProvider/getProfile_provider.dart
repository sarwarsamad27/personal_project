import 'package:flutter/material.dart';
import 'package:new_brand/models/profile/getSingleProfile_model.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/socketServices.dart';
import 'package:new_brand/viewModel/repository/profileRepository/getProfile_repository.dart';

class ProfileFetchProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ProfileScreenModel? _profileData;
  ProfileScreenModel? get profileData => _profileData;

  bool _fetched = false; // Track if already fetched
  bool _liveFollowerUpdatesStarted = false;

  final GetProfileRepository repository = GetProfileRepository();

  Future<void> getProfileOnce({bool refresh = false}) async {
    // A rebuild mid-fetch (e.g. from fast navigation) would otherwise fire a
    // second identical request in parallel — skip while one's in flight.
    if (_loading) return;
    // ❗ refresh = true => force re-fetch
    if (_fetched && !refresh) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profileData = await repository.getProfile();
      _fetched = true;
      _startLiveFollowerUpdates();
    } catch (e) {
      _error = "Failed to load profile";
    }

    _loading = false;
    notifyListeners();
  }

  // Live-updates followersCount when a buyer follows/unfollows this seller
  // while any screen reading this provider is open — otherwise the count
  // only changes after a manual refresh. The backend broadcasts
  // "follow:update" globally to every connected client (not room-scoped —
  // see followProfile.js), so this filters to this seller's own profileId.
  // This provider is registered once at the app root and lives for the
  // whole session, so — unlike a screen's State — there's no natural
  // dispose() to unregister the listener from; that's fine, it's meant to
  // live as long as the provider does (same long-lived-provider pattern as
  // ChatProvider's own socket setup).
  Future<void> _startLiveFollowerUpdates() async {
    if (_liveFollowerUpdatesStarted) return;
    _liveFollowerUpdatesStarted = true;

    final token = await LocalStorage.getToken() ?? "";
    if (token.isEmpty) return;
    final socket = await SocketService().ensureConnected(
      baseUrl: Global.imageUrl,
      token: token,
    );
    socket?.on("follow:update", (data) {
      if (data is! Map) return;
      if (data['profileId']?.toString() != _profileData?.profile?.sId) return;
      final count = data['followersCount'];
      if (count == null) return;
      _profileData?.profile?.followersCount = int.tryParse(count.toString());
      notifyListeners();
    });
  }

  // OPTIONAL: manual clear for future use
  void clearProfileCache() {
    _fetched = false;
    _profileData = null;
    notifyListeners();
  }
}
