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

  final GetProfileRepository repository = GetProfileRepository();
  Future<void> getProfile() async {
    _loading = true;
    notifyListeners();

    _profileData = await repository.getProfile();

    _loading = false;
    notifyListeners();
  }
  Future<void> fetchProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profileData = await repository.getProfile();
    } catch (e) {
      _error = "Failed to load profile";
    }

    _loading = false;
    notifyListeners();
  }
}
