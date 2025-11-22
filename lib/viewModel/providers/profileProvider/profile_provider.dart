import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/models/profile/createProfile_model.dart';
import 'package:new_brand/viewModel/repository/profileRepository/Createprofile_repository.dart';

class ProfileProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CreateProfileModel? _profileData;
  CreateProfileModel? get profileData => _profileData;

  final ProfileRepository repository = ProfileRepository();
  
  Future<void> createProfileProvider({
    required String token,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String description,
    File? image,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        description.isEmpty) {
      _errorMessage = "All fields are required";
      _loading = false;
      notifyListeners();
      return;
    }

    _profileData = await repository.createProfile(
       token: token,
      name: name,
      email: email,
      phone: phone,
      address: address,
      description: description,
      image: image,
    );

    _loading = false;
    notifyListeners();

    if (_profileData?.profile == null) {
      _errorMessage = _profileData?.message ?? "Profile creation failed";
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
