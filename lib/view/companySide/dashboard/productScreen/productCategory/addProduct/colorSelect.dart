import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class ColorSelect extends StatelessWidget {
  final ValueNotifier<List<Map<String, dynamic>>> colorNotifier;

  ColorSelect({super.key, required this.colorNotifier});

  final TextEditingController _colorController = TextEditingController();

  void _addColorsFromText(String text) {
    final names = text.split(RegExp(r'[ ,]+')).where((e) => e.isNotEmpty);
    final updated = List<Map<String, dynamic>>.from(colorNotifier.value);

    for (final name in names) {
      final exists = updated.any(
        (e) => e["name"].toLowerCase() == name.toLowerCase(),
      );
      if (!exists) {
        updated.add({"name": name, "color": null});
      }
    }

    colorNotifier.value = updated;
    _colorController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  headerText: "Color (optional)",
                  controller: _colorController,
                  hintText: 'Type color',
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () => _addColorsFromText(_colorController.text),
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Container(
                    width: 45.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(Icons.done, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          /// Colors List
          ValueListenableBuilder(
            valueListenable: colorNotifier,
            builder: (_, colors, __) {
              if (colors.isEmpty) return SizedBox();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((e) {
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
                        Text(e["name"], style: TextStyle(color: Colors.white)),
                        SizedBox(width: 5.w),
                        GestureDetector(
                          onTap: () {
                            colorNotifier.value = colors
                                .where((x) => x != e)
                                .toList();
                          },
                          child: Icon(
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
