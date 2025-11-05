// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customContainer.dart';

class SizeSelect extends StatelessWidget {
   SizeSelect({super.key});
  List<String> availableSizes = ["Small", "Medium", "Large", "XL", "XXL"];
    final ValueNotifier<List<String>> selectedSizes = ValueNotifier([]);


  @override
  Widget build(BuildContext context) {
    return  CustomAppContainer(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Size (Premium)',
                                  style: TextStyle(
                                    color: AppColor.textPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                ValueListenableBuilder<List<String>>(
                                  valueListenable: selectedSizes,
                                  builder: (context, sizes, _) {
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: availableSizes.map((size) {
                                        final isSelected = sizes.contains(size);
                                        return FilterChip(
                                          side: BorderSide(
                                            color: AppColor.primaryColor,
                                          ),
                                          label: Text(size),
                                          selected: isSelected,

                                          selectedColor: AppColor.primaryColor,
                                          checkmarkColor: Colors.white,
                                          onSelected: (value) {
                                            final updated = List<String>.from(
                                              sizes,
                                            );
                                            value
                                                ? updated.add(size)
                                                : updated.remove(size);
                                            selectedSizes.value = updated;
                                          },
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
  }
}