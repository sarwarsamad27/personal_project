import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/widgets/customContainer.dart';

class UploadImages extends StatelessWidget {
  final ValueNotifier<List<File>> selectedImages;

  UploadImages({super.key, required this.selectedImages});

  Future<void> _pickImages(BuildContext context) async {
    if (selectedImages.value.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only upload up to 5 images")),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      final newImages = picked.map((x) => File(x.path)).toList();
      final updated = List<File>.from(selectedImages.value)
        ..addAll(newImages.take(5 - selectedImages.value.length));

      selectedImages.value = updated;
      print("Selected Images: ${selectedImages.value}");
    } else {
      print("No images selected.");
    }
  }

  void _removeImage(int index) {
    final updated = List<File>.from(selectedImages.value)..removeAt(index);
    selectedImages.value = updated;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImages(context),
      child: ValueListenableBuilder<List<File>>(
        valueListenable: selectedImages,
        builder: (context, images, _) {
          return CustomAppContainer(
            height: 140.h,
            width: double.infinity,
            child: images.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.white, size: 40.sp),
                      SizedBox(height: 8.h),
                      Text("Upload Product Images",
                          style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                    ],
                  )
                : SizedBox(
                    height: 140.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.file(
                                images[index],
                                fit: BoxFit.cover,
                                width: 120.w,
                                height: 140.h,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
