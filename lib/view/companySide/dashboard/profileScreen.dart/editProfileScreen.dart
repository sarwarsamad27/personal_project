import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/models/profile/getSingleProfile_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/updateProfile_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController address;
  late TextEditingController description;

  final ValueNotifier<File?> _imageFile = ValueNotifier<File?>(null);

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.profile.name ?? "");
    email = TextEditingController(text: widget.profile.email ?? "");
    phone = TextEditingController(text: widget.profile.phone ?? "");
    address = TextEditingController(text: widget.profile.address ?? "");
    description = TextEditingController(text: widget.profile.description ?? "");
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    description.dispose();
    _imageFile.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) _imageFile.value = File(img.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Consumer<EditProfileProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Premium header ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220.h,
                pinned: true,
                backgroundColor: AppColor.primaryColor,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColor.primaryColor,
                              AppColor.primaryColor.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Subtle pattern circles
                      Positioned(
                        right: -30.w,
                        top: -20.h,
                        child: Container(
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20.w,
                        bottom: 10.h,
                        child: Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      // Avatar centered at bottom
                      Positioned(
                        bottom: 20.h,
                        left: 0,
                        right: 0,
                        child: Center(child: _buildAvatar()),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Form fields ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
                  child: Column(
                    children: [
                      _PremiumField(
                        controller: name,
                        label: 'Brand / Full Name',
                        icon: Icons.storefront_rounded,
                      ),
                      SizedBox(height: 14.h),
                      _PremiumField(
                        controller: phone,
                        label: 'Phone Number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 14.h),
                      _PremiumField(
                        controller: address,
                        label: 'Address',
                        icon: Icons.location_on_rounded,
                      ),
                      SizedBox(height: 14.h),
                      _PremiumField(
                        controller: description,
                        label: 'Description',
                        icon: Icons.description_rounded,
                        maxLines: 4,
                      ),
                      SizedBox(height: 32.h),

                      // Save button
                      provider.loading
                          ? SpinKitThreeBounce(
                              color: AppColor.primaryColor,
                              size: 28.sp,
                            )
                          : _SaveButton(onTap: () => _onSave(provider)),

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Avatar with camera overlay ──────────────────────────────────────
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          ValueListenableBuilder<File?>(
            valueListenable: _imageFile,
            builder: (_, image, __) {
              return Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: DecorationImage(
                    image: image != null
                        ? FileImage(image) as ImageProvider
                        : NetworkImage(
                            Global.getImageUrl(widget.profile.image ?? ''),
                          ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave(EditProfileProvider provider) async {
    await provider.updateProfile(
      profileId: widget.profile.sId!,
      name: name.text,
      email: email.text,
      phone: phone.text,
      address: address.text,
      description: description.text,
      image: _imageFile.value,
    );

    if (!mounted) return;

    if (provider.error != null) {
      AppToast.error(provider.error.toString());
      return;
    }

    // Pop immediately — don't await refresh (it was blocking navigation)
    if (mounted) Navigator.pop(context);
    Provider.of<ProfileFetchProvider>(context, listen: false)
        .getProfileOnce(refresh: true);
  }
}

// ── Premium Text Field ───────────────────────────────────────────────────────
class _PremiumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;

  const _PremiumField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF1E1E2D),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 12.w, right: 8.w),
            child: Icon(icon, color: AppColor.primaryColor, size: 20.sp),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 44.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: AppColor.primaryColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}

// ── Save Button ──────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor,
              AppColor.primaryColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
