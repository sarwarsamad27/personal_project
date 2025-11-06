import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/widgets/infoScreen.dart';
import 'package:new_brand/widgets/customContainer.dart';

class AllCondition extends StatelessWidget {
   AllCondition({super.key});
  final List<Map<String, dynamic>> profileOptions = [
    {"icon": LucideIcons.fileText, "label": "Terms & Conditions"},
    {"icon": LucideIcons.phoneCall, "label": "Contact Us"},
    {"icon": LucideIcons.info, "label": "About"},
    {"icon": LucideIcons.helpCircle, "label": "FAQ"},
    {"icon": LucideIcons.logOut, "label": "Logout"},
  ];

  @override
  Widget build(BuildContext context) {
    return  CustomAppContainer(
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
                  );
  }
}