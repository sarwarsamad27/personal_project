import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/categoryProvider/createCategory_provider.dart';
import 'package:new_brand/widgets/customImageContainer.dart';
import 'package:provider/provider.dart';

import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateCategoryProvider>();

    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 50.h),
          child: Column(
            children: [
              Text(
                "Add Category",
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
                  child: SingleChildScrollView(
                    child: CustomAppContainer(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: provider.loading
                                ? null
                                : () => context
                                      .read<CreateCategoryProvider>()
                                      .pickImage(),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.r),
                              child: CustomImageContainer(
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
                                        borderRadius: BorderRadius.circular(
                                          25.r,
                                        ),
                                        child: Image.file(
                                          provider.image as File,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
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
                            onTap: provider.loading
                                ? null
                                : () async {
                                    final token = await LocalStorage.getToken();

                                    final success = await context
                                        .read<CreateCategoryProvider>()
                                        .createCategory(token ?? "");

                                    if (!context.mounted) return;

                                    if (success) {
                                      // ✅ CHANGE: Reset fields pehle
                                      context
                                          .read<CreateCategoryProvider>()
                                          .resetFields();

                                      // ✅ CHANGE: Pop with true to indicate success
                                      Navigator.pop(context, true);
                                    } else {
                                      AppToast.warning(
                                        "Please select image and name",
                                      );
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
    );
  }
}
