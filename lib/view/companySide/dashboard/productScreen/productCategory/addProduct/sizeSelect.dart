// ignore_for_file: must_be_immutable, fileNames

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class SizeSelect extends StatelessWidget {
    final ValueNotifier<List<String>> selectedSizes;

  SizeSelect({super.key, required this.selectedSizes});

  final TextEditingController _sizeController = TextEditingController();

void _addSizesFromText(String text) {
  final names = text.split(RegExp(r'[ ,]+')).where((e) => e.isNotEmpty);
  final updated = List<String>.from(selectedSizes.value);
  for (var name in names) {
    if (!updated.contains(name)) updated.add(name);
  }
  selectedSizes.value = updated;

  // Debugging print to confirm the sizes
  print("Selected Sizes: ${selectedSizes.value}");
  _sizeController.clear();
}

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  headerText: "Size (optional)",
                  controller: _sizeController,
                  hintText: "Type size (e.g. M, L, 28, 30)",
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () => _addSizesFromText(_sizeController.text),
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Container(
                    width: 45.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.done, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          /// Wrap of sizes
          ValueListenableBuilder<List<String>>(
            valueListenable: selectedSizes,
            builder: (context, sizes, _) {
              if (sizes.isEmpty) return const SizedBox();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sizes.map((size) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(size, style: const TextStyle(color: Colors.white)),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () {
                            selectedSizes.value = sizes
                                .where((e) => e != size)
                                .toList();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
