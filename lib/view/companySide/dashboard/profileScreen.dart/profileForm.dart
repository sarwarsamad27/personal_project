import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:new_brand/viewModel/providers/AuthProvider/login_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/profile_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:provider/provider.dart';

class ProfileFormScreen extends StatefulWidget {
  final String email;
  const ProfileFormScreen({super.key,required this.email});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
@override
void initState() {
  super.initState();
  _emailController.text = widget.email; // set readonly email
}

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
     final emailProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              children: [
                Text(
                  "Profile Form",
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 40.h),

                // 🔹 Main Glass Container
                Expanded(
                  child: Center(
                    child: CustomAppContainer(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔹 Profile Image Picker
                            GestureDetector(
                              onTap: _pickImage,
                              child: CustomAppContainer(
                                height: 140.h,
                                width: 140.w,
                                child: _selectedImage == null
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
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: 30.h),

                            // 🔹 Name
                            CustomTextField(
                              controller: _nameController,
                              hintText: "Enter your name",
                              headerText: "Full Name",
                            ),
                            SizedBox(height: 20.h),

                            // 🔹 Email
                            CustomTextField(
                              controller: _emailController,
                              
                              headerText: "Email Address",
                              readOnly: true,
                            ),
                            SizedBox(height: 20.h),

                            // 🔹 Phone
                            CustomTextField(
                              controller: _phoneController,
                              hintText: "Enter your phone number",
                              headerText: "Phone Number",
                            ),
                            SizedBox(height: 20.h),

                            // 🔹 Address
                            CustomTextField(
                              controller: _addressController,
                              hintText: "Enter your address",
                              headerText: "Address",
                            ),
                            SizedBox(height: 20.h),

                            // 🔹 Description
                            CustomTextField(
                              controller: _descriptionController,
                              hintText: "Write something about yourself",
                              headerText: "Description",
                              height: 120.h,
                            ),

                            SizedBox(height: 30.h),

                            // 🔹 Save Button
                            CustomButton(
                              text: "Save Profile",
                              onTap: () async {
                                provider.clearError();

                                final token = await LocalStorage.getToken();

                                await provider.createProfileProvider(
                                  token: token ?? "",
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  phone: _phoneController.text,
                                  address: _addressController.text,
                                  description: _descriptionController.text,
                                  image: _selectedImage,
                                );

                                if (provider.loading)
                                  return;

                                if (provider.profileData?.profile != null) {
                                  AppToast.success(
                                    "Profile create successfully",
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CompanyHomeScreen(),
                                    ),
                                  );
                                } else {
                                  AppToast.error(provider.errorMessage ?? "Failed");
                                }
                              },
                            ),
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
      ),
    );
  }
}
