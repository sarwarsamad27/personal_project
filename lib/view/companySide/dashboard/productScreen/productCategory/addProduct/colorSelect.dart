import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class ColorSelect extends StatelessWidget {
  ColorSelect({super.key});
  final TextEditingController _colorController = TextEditingController();

  final ValueNotifier<List<Map<String, dynamic>>> selectedColorItems =
      ValueNotifier([]);
  void _addColorsFromText(String text) {
    final colorNames = text.split(RegExp(r'[ ,]+')).where((e) => e.isNotEmpty);
    final newEntries = <Map<String, dynamic>>[];

    for (final name in colorNames) {
      final alreadyExists = selectedColorItems.value.any(
        (item) => item["name"].toLowerCase() == name.toLowerCase(),
      );
      if (!alreadyExists) {
        // ❌ color detect removed
        // ✔ always store name only
        newEntries.add({"name": name, "color": null});
      }
    }

    if (newEntries.isNotEmpty) {
      selectedColorItems.value = [...selectedColorItems.value, ...newEntries];
      _colorController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  headerText: "Color (optional)",
                  controller: _colorController,
                  hintText: 'Type color & tap icon →',
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () => _addColorsFromText(_colorController.text),
                child: Padding(
                  padding: EdgeInsets.only(top: 28.h),
                  child: Container(
                    width: 45.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // Display colors
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: selectedColorItems,
            builder: (context, colorItems, _) {
              if (colorItems.isEmpty) return const SizedBox();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorItems.map((e) {
                  final color = e['color'];
                  final name = e['name'];

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: color ?? AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (color == null)
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        if (color != null)
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () {
                            selectedColorItems.value = colorItems
                                .where((item) => item != e)
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
