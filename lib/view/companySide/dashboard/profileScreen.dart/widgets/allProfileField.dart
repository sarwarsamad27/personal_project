import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

import '../../../../../models/profile/getSingleProfile_model.dart';

class AllField extends StatelessWidget {
  final Profile profile;

  AllField({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      child: Column(
        children: [
          CustomTextField(
            controller: TextEditingController(text: profile.name ?? ""),
            headerText: "Name",
            readOnly: true,
          ),
          SizedBox(height: 15.h),

          CustomTextField(
            controller: TextEditingController(text: profile.email ?? ""),
            headerText: "Email",
            readOnly: true,
          ),
          SizedBox(height: 15.h),

          CustomTextField(
            controller: TextEditingController(text: profile.phone ?? ""),
            headerText: "Phone",
            readOnly: true,
          ),
          SizedBox(height: 15.h),

          CustomTextField(
            controller: TextEditingController(text: profile.address ?? ""),
            headerText: "Address",
            readOnly: true,
          ),
          SizedBox(height: 15.h),

          CustomTextField(
            height: 110.h,
            controller: TextEditingController(text: profile.description ?? ""),
            headerText: "Description",
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
