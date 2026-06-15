import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/colorSelect.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/sizeSelect.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/uploadImages.dart';
import 'package:new_brand/viewModel/providers/productProvider/AnalyzeProductProvider.dart';
import 'package:new_brand/viewModel/providers/productProvider/addProduct_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/customValidation.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class AddProductScreen extends StatelessWidget {
  final Categories category;
  AddProductScreen({super.key, required this.category});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _beforePriceController = TextEditingController();
  final TextEditingController _afterPriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ValueNotifier<List<File>> selectedImagesNotifier = ValueNotifier([]);
  final ValueNotifier<File?> selectedVideoNotifier = ValueNotifier(null);
  final ValueNotifier<List<String>> selectedSizesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> selectedColorsNotifier =
      ValueNotifier([]);

  Future<void> _analyzeImages(BuildContext context, List<File> images) async {
    final token = await LocalStorage.getToken();
    final analyzeProvider = Provider.of<AnalyzeProductProvider>(
      context,
      listen: false,
    );
    _nameController.text = "Analyzing...";
    _descriptionController.text = "Please wait...";
    analyzeProvider.analyzeImage(
      token: token ?? '',
      images: images,
      onSuccess: (name, description) {
        _nameController.text = name;
        _descriptionController.text = description;
      },
      onError: (error) {
        _nameController.text = "";
        _descriptionController.text = "";
        AppToast.show("Could not analyze image");
      },
    );
  }

  void _calculateDiscount(BuildContext context) {
    final before = double.tryParse(_beforePriceController.text.trim());
    final after = double.tryParse(_afterPriceController.text.trim());
    if (before == null || after == null) {
      _discountController.text = "";
      return;
    }
    if (after > before) {
      AppToast.show(
        "After discount price must be less than before discount price",
      );
      _afterPriceController.clear();
      _discountController.text = "";
      return;
    }
    final discount = ((before - after) / before) * 100;
    _discountController.text = "${discount.toStringAsFixed(1)}%";
  }

  static const int _maxVideoMB = 50;

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.length();
    final mb = bytes / (1024 * 1024);

    if (mb > _maxVideoMB) {
      AppToast.show(
        "Video is ${mb.toStringAsFixed(1)} MB — max allowed is $_maxVideoMB MB. Please trim or compress it.",
      );
      return;
    }

    selectedVideoNotifier.value = file;
  }

  void _saveProduct(BuildContext context) async {
    final token = await LocalStorage.getToken();
    final provider = Provider.of<AddProductProvider>(context, listen: false);

    if (selectedImagesNotifier.value.isEmpty ||
        _nameController.text.isEmpty ||
        _nameController.text == "Analyzing..." ||
        _beforePriceController.text.isEmpty ||
        _afterPriceController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      AppToast.show(
        "Please fill all required fields and add at least one image",
      );
      return;
    }

    final weight = int.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      AppToast.show("Please enter valid weight in grams");
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity < 0) {
      AppToast.show("Please enter valid quantity");
      return;
    }

    final validImages = selectedImagesNotifier.value
        .where((f) => f.existsSync())
        .toList();
    if (validImages.isEmpty) {
      AppToast.show("Selected images not found. Please re-select.");
      return;
    }

    provider.addProduct(
      token: token,
      categoryId: category.sId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      images: validImages,
      video: selectedVideoNotifier.value,
      beforePrice: int.tryParse(_beforePriceController.text),
      afterPrice: int.tryParse(_afterPriceController.text),
      size: selectedSizesNotifier.value,
      color: selectedColorsNotifier.value
          .map((e) => e["name"].toString())
          .toList(),
      quantity: quantity,
      weightInGrams: weight,
      onSuccess: () {
        AppToast.show("Product added successfully!");
        Navigator.pop(context);
      },
      onError: (msg) => AppToast.show(msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20.h, left: 24.w, right: 24.w),
        child: Consumer<AddProductProvider>(
          builder: (context, provider, _) {
            final hasVideo = selectedVideoNotifier.value != null;
            String btnText = "Add Product";
            if (provider.isLoading) {
              btnText = hasVideo
                  ? "Uploading… (video may take 1-2 min)"
                  : "Adding...";
            }
            return CustomButton(
              text: btnText,
              onTap: provider.isLoading ? null : () => _saveProduct(context),
            );
          },
        ),
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            children: [
              Expanded(
                child: CustomAppContainer(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── IMAGES (mandatory) ──
                        UploadImages(
                          selectedImages: selectedImagesNotifier,
                          onImageSelected: (List<File> images) =>
                              _analyzeImages(context, images),
                        ),
                        SizedBox(height: 12.h),

                        // ── AI analyzing indicator ──
                        Consumer<AnalyzeProductProvider>(
                          builder: (context, analyzeProvider, _) {
                            if (!analyzeProvider.isAnalyzing)
                              return const SizedBox.shrink();
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "AI analyzing image...",
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // ── VIDEO (optional, 30 sec) ──
                        _VideoUploadSection(
                          videoNotifier: selectedVideoNotifier,
                          onPick: () => _pickVideo(context),
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _nameController,
                          hintText: "Enter product name",
                          headerText: 'Product Name',
                          validator: Validators.required,
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _descriptionController,
                          hintText: "Enter product description",
                          headerText: 'Description',
                          validator: Validators.required,
                          maxLines: 3,
                          minLines: 1,
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _beforePriceController,
                          hintText: "Enter before discount price (e.g. 4999)",
                          headerText: 'Before Discount Price',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateDiscount(context),
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _afterPriceController,
                          hintText: "Enter after discount price (e.g. 3999)",
                          headerText: 'After Discount Price',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateDiscount(context),
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _discountController,
                          hintText: "Discount %",
                          headerText: 'Discount Percentage',
                          readOnly: true,
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _weightController,
                          hintText: "Enter weight in grams (e.g. 500)",
                          headerText: 'Weight (in grams) *',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20.h),

                        CustomTextField(
                          controller: _quantityController,
                          hintText: "Enter available quantity (e.g. 50)",
                          headerText: 'Quantity *',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20.h),

                        SizeSelect(selectedSizes: selectedSizesNotifier),
                        SizedBox(height: 20.h),
                        ColorSelect(colorNotifier: selectedColorsNotifier),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoUploadSection extends StatelessWidget {
  final ValueNotifier<File?> videoNotifier;
  final VoidCallback onPick;

  const _VideoUploadSection({
    required this.videoNotifier,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<File?>(
      valueListenable: videoNotifier,
      builder: (context, video, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Product Video (optional — max 30 sec, max 50 MB)",
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            ),
            SizedBox(height: 8.h),
            if (video == null)
              GestureDetector(
                onTap: onPick,
                child: Container(
                  height: 80.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_outlined,
                        color: Colors.white54,
                        size: 26.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Add Video",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              FutureBuilder<int>(
                future: video.length(),
                builder: (_, snap) {
                  final mb = snap.hasData
                      ? (snap.data! / (1024 * 1024)).toStringAsFixed(1)
                      : "…";
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          _LocalVideoPreview(file: video),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => videoNotifier.value = null,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Video size: $mb MB",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _LocalVideoPreview extends StatefulWidget {
  final File file;
  const _LocalVideoPreview({required this.file});

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_initialized) {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
          setState(() {});
        }
      },
      child: Container(
        height: 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_initialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const CircularProgressIndicator(color: Colors.white),
            if (_initialized && !_controller.value.isPlaying)
              const Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 48,
              ),
          ],
        ),
      ),
    );
  }
}
