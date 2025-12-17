import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_brand/models/profile/updateProfile_model.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/repository/profileRepository/updateProfile_repository.dart';

class EditProfileProvider with ChangeNotifier {
  final UpdateProfileRepository _repo = UpdateProfileRepository();

  bool loading = false;
  String? error;
  UpdateProfileModel? data;

  Future<void> updateProfile({
    required String profileId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String description,
    File? image,
  }) async {
    loading = true;
    notifyListeners();

    final token = await LocalStorage.getToken();

    final fields = {
      "profileId": profileId,
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "description": description,
    };

    final res = await _repo.updateProfile(
      token: token!,
      fields: fields,
      image: image,
    );

    loading = false;

    if (res.message?.contains("Error") == true) {
      error = res.message;
    } else {
      data = res;
    }

    notifyListeners();
  }
}
