import 'package:flutter/material.dart';
import 'package:new_brand/models/profile/getSingleProfile_model.dart';
import 'package:new_brand/viewModel/repository/profileRepository/getProfile_repository.dart';

class ProfileFetchProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ProfileScreenModel? _profileData;
  ProfileScreenModel? get profileData => _profileData;

  bool _fetched = false; // Track if already fetched

  final GetProfileRepository repository = GetProfileRepository();

  Future<void> getProfileOnce({bool refresh = false}) async {
    // ❗ refresh = true => force re-fetch
    if (_fetched && !refresh) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profileData = await repository.getProfile();
      _fetched = true;
    } catch (e) {
      _error = "Failed to load profile";
    }

    _loading = false;
    notifyListeners();
  }

  // OPTIONAL: manual clear for future use
  void clearProfileCache() {
    _fetched = false;
    _profileData = null;
    notifyListeners();
  }
}
