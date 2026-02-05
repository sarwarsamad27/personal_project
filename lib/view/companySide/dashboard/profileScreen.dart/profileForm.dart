import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:new_brand/viewModel/providers/profileProvider/profile_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customImageContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:provider/provider.dart';

class ProfileFormScreen extends StatefulWidget {
  final String email;
  const ProfileFormScreen({super.key, required this.email});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email; // ✅ login se aayi email show
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _selectedImage.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _selectedImage.value = File(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>(); // ✅ listen: false

    return Scaffold(
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 30.h,
            bottom: 10.h,
          ),
          child: Column(
            children: [
              Text(
                "Profile Form",
                style: TextStyle(
                  fontSize: 28.sp,
                  color: AppColor.appimagecolor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 20.h),

              Expanded(
                child: Center(
                  child: CustomAppContainer(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: ValueListenableBuilder<File?>(
                              valueListenable: _selectedImage,
                              builder: (context, image, child) {
                                return CustomImageContainer(
                                  height: 140.h,
                                  width: 140.w,
                                  child: image == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              color: Colors.white,
                                              size: 40.sp,
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "Upload Image",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ],
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          child: Image.file(
                                            image,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 30.h),

                          CustomTextField(
                            controller: _nameController,
                            hintText: "Enter your name",
                            headerText: "Full Name",
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _emailController,
                            headerText: "Email Address",
                            readOnly: true, // ✅ locked
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _phoneController,
                            hintText: "Enter your phone number",
                            keyboardType: TextInputType.number,
                            headerText: "Phone Number",
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _addressController,
                            hintText: "Enter your address",
                            headerText: "Address",
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _descriptionController,
                            hintText: "Write something about yourself",
                            headerText: "Description",
                            height: 120.h,
                          ),

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColor.appimagecolor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
        child: CustomButton(
          text: "Save Profile",
          onTap: () async {
            provider.clearError();

            final token = await LocalStorage.getToken();
            if (token == null || token.isEmpty) {
              AppToast.error("Session expired. Please login again.");
              return;
            }

            await provider.createProfileProvider(
              token: token,
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              description: _descriptionController.text.trim(),
              image: _selectedImage.value,
            );

            if (!mounted) return;

            if (provider.profileData?.profile != null) {
              AppToast.success("Profile created successfully");

              // ✅ now profile exists -> home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CompanyHomeScreen()),
              );
            } else {
              AppToast.error(provider.errorMessage ?? "Failed");
            }
          },
        ),
      ),
    );
  }
}
