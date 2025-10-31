import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/infoScreen.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/userReviews.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  // Sample Reviews Data
  final List<Map<String, String>> reviews = [
    {
      "user": "Alice",
      "feedback": "Great service, very responsive!",
      "date": "2025-10-25",
    },
    {
      "user": "Bob",
      "feedback": "Product quality is amazing.",
      "date": "2025-10-24",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
    {
      "user": "Charlie",
      "feedback": "Fast delivery, highly recommended!",
      "date": "2025-10-22",
    },
  ];

  // Profile options
  final List<Map<String, dynamic>> profileOptions = [
    {"icon": LucideIcons.fileText, "label": "Terms & Conditions"},
    {"icon": LucideIcons.phoneCall, "label": "Contact Us"},
    {"icon": LucideIcons.info, "label": "About"},
    {"icon": LucideIcons.helpCircle, "label": "FAQ"},
    {"icon": LucideIcons.logOut, "label": "Logout"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 124.r,
                        height: 124.r,
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primaryColor,
                        ),
                        child: CircleAvatar(
                          radius: 60.r,
                          backgroundImage: const NetworkImage(
                            "https://i.pravatar.cc/300",
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Add image picker for profile
                          },
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              LucideIcons.edit3,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // 🔹 Name, Email, Phone
                  CustomAppContainer(
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
                  ),
                  SizedBox(height: 30.h),

                  // 🔹 Reviews / Feedback Section
                  // 🔹 Reviews / Feedback Section
                  // 🔹 Reviews Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "User Reviews",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // View All Reviews Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserReviewsScreen(reviews: reviews),
                        ),
                      );
                    },
                    child: CustomAppContainer(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h,
                        horizontal: 20.w,
                      ),

                      child: Row(
                        children: [
                          Icon(LucideIcons.star, color: Colors.white),
                          SizedBox(width: 10.w),
                          Text(
                            "View All Reviews",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Spacer(),
                          Icon(LucideIcons.chevronRight, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Scrollable container for reviews
                  SizedBox(height: 30.h),

                  // 🔹 Other Profile Options (Terms, Contact, About...)
                  CustomAppContainer(
                    padding: EdgeInsets.all(15.w),

                    child: Column(
                      children: profileOptions.map((option) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(option["icon"], color: Colors.white),
                          title: Text(
                            option["label"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            LucideIcons.chevronRight,
                            color: Colors.white,
                          ),
                          onTap: () {
                            switch (option["label"]) {
                              case "Terms & Conditions":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InfoScreen(
                                      title: "Terms & Conditions",
                                      content:
                                          "Here are your Terms & Conditions...",
                                    ),
                                  ),
                                );
                                break;
                              case "Contact Us":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InfoScreen(
                                      title: "Contact Us",
                                      content:
                                          "Contact us at: contact@company.com\nPhone: +92 300 1234567",
                                    ),
                                  ),
                                );
                                break;
                              case "About":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InfoScreen(
                                      title: "About",
                                      content:
                                          "This app is developed by XYZ company...",
                                    ),
                                  ),
                                );
                                break;
                              case "FAQ":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InfoScreen(
                                      title: "FAQ",
                                      content:
                                          "Q1: How to use this app?\nA1: ...\n\nQ2: Payment methods?\nA2: ...",
                                    ),
                                  ),
                                );
                                break;
                              case "Logout":
                                // Handle logout here
                                break;
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Custom text field card
}
