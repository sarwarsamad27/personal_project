import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:new_brand/view/companySide/dashboard/dashboardScreen/dashboardScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveProfile() {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and upload image"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                          25.r,
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
                              hintText: "Enter your email",
                              headerText: "Email Address",
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
                              onTap:
                                  //  _saveProfile,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CompanyHomeScreen(),
                                      ),
                                    );
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
