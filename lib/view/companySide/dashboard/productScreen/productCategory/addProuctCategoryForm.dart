import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/createCategory_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateCategoryProvider>(context);

    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              children: [
                Text(
                  "Add Category",
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 40.h),

                Expanded(
                  child: Center(
                    child: CustomAppContainer(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              provider.pickImage();
                            },
                            child: CustomAppContainer(
                              height: 140.h,
                              width: 140.w,
                              child: provider.image == null
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
                                      borderRadius: BorderRadius.circular(25.r),
                                      child: Image.file(
                                        provider.image as File,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: 30.h),

                          CustomTextField(
                            controller: provider.nameController,
                            hintText: "Enter category name",
                            headerText: 'Category Name',
                          ),

                          SizedBox(height: 30.h),

                          CustomButton(
                            text: provider.loading
                                ? "Please wait..."
                                : "Add Category",
                            onTap: () async {
                              final token =
                                  await LocalStorage.getToken(); // ← replace later

                              bool success = await provider.createCategory(
                                token ?? "",
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Category added successfully!",
                                    ),
                                  ),
                                );

                                provider.resetFields();

                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please select image and name",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
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
