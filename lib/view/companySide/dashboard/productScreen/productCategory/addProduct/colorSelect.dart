import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';

class ColorSelect extends StatelessWidget {
  ColorSelect({super.key});
  final TextEditingController _colorController = TextEditingController();
  Color? _getColorFromName(String name) {
    final colorName = name.toLowerCase().trim();
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      default:
        return null;
    }
  }

  final ValueNotifier<List<Map<String, dynamic>>> selectedColorItems =
      ValueNotifier([]);
  void _addColorsFromText(String text) {
    final colorNames = text.split(RegExp(r'[ ,]+')).where((e) => e.isNotEmpty);
    final newEntries = <Map<String, dynamic>>[];

    for (final name in colorNames) {
      final color = _getColorFromName(name);
      final alreadyExists = selectedColorItems.value.any(
        (item) => item["name"].toLowerCase() == name.toLowerCase(),
      );
      if (!alreadyExists) {
        newEntries.add({"name": name, "color": color});
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
                  headerText: "Color",
                  controller: _colorController,
                  hintText: 'Type color & tap icon →',
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () => _addColorsFromText(_colorController.text),
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.color_lens,
                    color: Colors.white,
                    size: 24,
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
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: color ?? AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(20.r),
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
