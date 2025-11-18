import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class AllField extends StatelessWidget {
  AllField({super.key});
  final TextEditingController _nameController = TextEditingController(
    text: "John Doe",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "johndoe@email.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+92 300 1234567",
  );
  final TextEditingController _addressController = TextEditingController(
    text: "clifton karachi",
  );
  final TextEditingController _descriptionController = TextEditingController(
    text:
        "I/AssistStructure( 4158): Flattened final assist data: 500 bytes, containing 1 windows, 3 views",
  );

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            headerText: "Name",
            readOnly: true,
          ),
          SizedBox(height: 15.h),
          CustomTextField(
            controller: _emailController,
            headerText: "Email",
            readOnly: true,
          ),
          SizedBox(height: 15.h),
          CustomTextField(
            controller: _phoneController,
            headerText: "Phone",
            readOnly: true,
          ),
          SizedBox(height: 15.h),
          CustomTextField(
            controller: _addressController,
            headerText: "Address",
            readOnly: true,
          ),

          SizedBox(height: 15.h),
          CustomTextField(
            height: 110.h,
            controller: _descriptionController,
            headerText: "Description",
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
