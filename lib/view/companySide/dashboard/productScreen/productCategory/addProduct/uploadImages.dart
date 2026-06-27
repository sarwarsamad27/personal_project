import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/toast.dart';

class UploadImages extends StatelessWidget {
  final ValueNotifier<List<File>> selectedImages;
  final Function(List<File> images)? onImageSelected; // ✅ all selected images

  const UploadImages({
    super.key,
    required this.selectedImages,
    this.onImageSelected,
  });

  Future<void> _pickImages(BuildContext context) async {
    if (selectedImages.value.length >= 5) {
      AppToast.show("You can only upload up to 5 images");
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      final newImages = picked.map((x) => File(x.path)).toList();
      final updated = List<File>.from(selectedImages.value)
        ..addAll(newImages.take(5 - selectedImages.value.length));

      selectedImages.value = updated;

      // ✅ Saari selected images ek sath analyze karo
      if (onImageSelected != null && updated.isNotEmpty) {
        onImageSelected!(updated);
      }
    }
  }

  void _removeImage(int index) {
    final updated = List<File>.from(selectedImages.value)..removeAt(index);
    selectedImages.value = updated;

    // ✅ Remaining images ke sath re-analyze karo
    if (onImageSelected != null && updated.isNotEmpty) {
      onImageSelected!(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<File>>(
      valueListenable: selectedImages,
      builder: (context, images, _) {
        final canAddMore = images.length < 5;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Product Images (Max 5)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 110.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...List.generate(images.length, (index) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 10.w),
                          width: 110.w,
                          height: 110.h,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Image.file(images[index], fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (canAddMore)
                    GestureDetector(
                      onTap: () => _pickImages(context),
                      child: Container(
                        width: 110.w,
                        height: 110.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColor.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColor.primaryColor,
                          size: 30.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
