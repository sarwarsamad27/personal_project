import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/productProvider/editProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/getSingleProduct_provider.dart';
import 'package:new_brand/viewModel/providers/productProvider/updateProduct_provider.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class EditProductDialog extends StatelessWidget {
  final String productId;
  final String categoryId;
  final List<String> imageUrls;
  final String? videoUrl;
  final String name;
  final String description;
  final String color;
  final String size;
  final String price;
  final int quantity;
  final int weightInGrams;

  const EditProductDialog({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.imageUrls,
    this.videoUrl,
    required this.name,
    required this.description,
    required this.color,
    required this.size,
    required this.price,
    required this.quantity,
    required this.weightInGrams,
  });

  @override
  Widget build(BuildContext context) {
    final oldPrice = price.replaceAll("PKR", "").replaceAll(":", "").trim();
    final bool hasColors =
        color.trim().isNotEmpty && color.trim().toLowerCase() != "n/a";
    final bool hasSizes =
        size.trim().isNotEmpty && size.trim().toLowerCase() != "n/a";

    return ChangeNotifierProvider(
      create: (_) => EditProductNotifier(
        oldName: name,
        oldPrice: oldPrice,
        oldDescription: description,
        oldColor: color,
        oldSize: size,
        oldQuantity: quantity,
        oldWeight: weightInGrams,
        oldImages: imageUrls,
        oldVideoUrl: videoUrl,
      ),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
        backgroundColor: Colors.transparent,
        child: CustomAppContainer(
          color: Colors.white70,
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          child: Consumer<EditProductNotifier>(
            builder: (context, s, _) {
              final bool canUpdate = s.isChanged && s.isValid;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Product",
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: AppColor.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Images ──────────────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Product Images (Max 5)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 110.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...List.generate(s.existingImages.length, (i) {
                            return _ExistingImageTile(
                              imagePath: s.existingImages[i],
                              onRemove: () => s.removeExisting(i),
                            );
                          }),
                          ...List.generate(s.newImages.length, (i) {
                            return _NewImageTile(
                              file: s.newImages[i],
                              onRemove: () => s.removeNew(i),
                            );
                          }),
                          if (s.canAddMore)
                            GestureDetector(
                              onTap: () => s.pickImages(),
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

                    SizedBox(height: 20.h),

                    // ── Video ────────────────────────────────────────────────
                    _VideoSection(notifier: s, context: context),

                    SizedBox(height: 20.h),

                    // ── Text fields ──────────────────────────────────────────
                    CustomTextField(
                      controller: s.nameController,
                      headerText: "Product Name",
                      hintText: "Enter product name",
                      prefixIcon: Icons.edit,
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      controller: s.priceController,
                      headerText: "Price",
                      hintText: "Enter price (PKR)",
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      controller: s.descriptionController,
                      headerText: "Description",
                      hintText: "Write description",
                      height: 100.h,
                    ),
                    SizedBox(height: 15.h),

                    if (hasColors) ...[
                      CustomTextField(
                        controller: s.colorController,
                        headerText: "Color",
                        hintText: "Enter product color",
                        prefixIcon: Icons.palette_outlined,
                      ),
                      SizedBox(height: 15.h),
                    ],
                    if (hasSizes) ...[
                      CustomTextField(
                        controller: s.sizeController,
                        headerText: "Size",
                        hintText: "Enter available size",
                        prefixIcon: Icons.straighten,
                      ),
                      SizedBox(height: 15.h),
                    ],

                    CustomTextField(
                      controller: s.weightController,
                      headerText: "Weight (grams) *",
                      hintText: "Enter weight in grams (e.g. 500)",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.scale_outlined,
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      controller: s.quantityController,
                      headerText: "Quantity *",
                      hintText: "Enter available quantity (e.g. 50)",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.inventory_2_outlined,
                    ),
                    SizedBox(height: 25.h),

                    // ── Buttons ──────────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Opacity(
                            opacity: canUpdate ? 1.0 : 0.5,
                            child: CustomButton(
                              text: "Update",
                              onTap: canUpdate
                                  ? () async {
                                      await s.removeMissingFiles();

                                      final validNewImages = s.newImages
                                          .where((f) => f.existsSync())
                                          .toList();

                                      final token =
                                          await LocalStorage.getToken() ?? "";
                                      final provider =
                                          Provider.of<UpdateProductProvider>(
                                            context,
                                            listen: false,
                                          );

                                      await provider.updateProduct(
                                        productId: productId,
                                        token: token,
                                        name: s.nameController.text.trim(),
                                        description: s
                                            .descriptionController
                                            .text
                                            .trim(),
                                        afterDiscountPrice:
                                            int.tryParse(
                                              s.priceController.text.trim(),
                                            ) ??
                                            0,
                                        beforeDiscountPrice:
                                            int.tryParse(
                                              s.priceController.text.trim(),
                                            ) ??
                                            0,
                                        size: hasSizes
                                            ? s.sizeController.text
                                                  .trim()
                                                  .split(',')
                                            : <String>[],
                                        color: hasColors
                                            ? s.colorController.text
                                                  .trim()
                                                  .split(',')
                                            : <String>[],
                                        quantity:
                                            int.tryParse(
                                              s.quantityController.text.trim(),
                                            ) ??
                                            0,
                                        weightInGrams:
                                            int.tryParse(
                                              s.weightController.text.trim(),
                                            ) ??
                                            500,
                                        images: validNewImages,
                                        keepImages: s.existingImages,
                                        deleteImages: s.deletedExistingImages,
                                        video: s.newVideoFile,
                                        removeVideo: s.videoRemoved,
                                      );

                                      if (provider
                                              .updateProductModel
                                              ?.product !=
                                          null) {
                                        Navigator.pop(context);
                                        AppToast.show(
                                          "Product updated successfully",
                                        );
                                        final getProvider =
                                            Provider.of<
                                              GetSingleProductProvider
                                            >(context, listen: false);
                                        final token2 =
                                            await LocalStorage.getToken() ?? "";
                                        await getProvider.fetchSingleProducts(
                                          token: token2,
                                          categoryId: categoryId,
                                          productId: productId,
                                        );
                                      } else {
                                        AppToast.error("Update failed");
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Video section widget ──────────────────────────────────────────────────────
class _VideoSection extends StatelessWidget {
  final EditProductNotifier notifier;
  final BuildContext context;

  const _VideoSection({required this.notifier, required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Product Video (optional, max 30 sec / 50 MB)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimaryColor,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // New local file selected
        if (notifier.newVideoFile != null)
          _LocalVideoPreview(
            file: notifier.newVideoFile!,
            onRemove: notifier.removeVideo,
            onReplace: () => _pickVideo(context, notifier),
          )
        // Existing network video (not removed)
        else if (notifier.currentVideoUrl != null &&
            notifier.currentVideoUrl!.isNotEmpty)
          _NetworkVideoPreview(
            url: notifier.currentVideoUrl!,
            onRemove: notifier.removeVideo,
            onReplace: () => _pickVideo(context, notifier),
          )
        // No video
        else
          GestureDetector(
            onTap: () => _pickVideo(context, notifier),
            child: Container(
              height: 80.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    color: AppColor.primaryColor,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Add Video",
                    style: TextStyle(
                      color: AppColor.primaryColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickVideo(
    BuildContext ctx,
    EditProductNotifier notifier,
  ) async {
    final error = await notifier.pickVideo();
    if (error != null && ctx.mounted) {
      AppToast.show(error);
    }
  }
}

// ── Local video preview (newly picked) ───────────────────────────────────────
class _LocalVideoPreview extends StatefulWidget {
  final File file;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const _LocalVideoPreview({
    required this.file,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoCard(
      child: _ready
          ? GestureDetector(
              onTap: () => _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _ctrl.value.aspectRatio,
                    child: VideoPlayer(_ctrl),
                  ),
                  if (!_ctrl.value.isPlaying)
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white70,
                      size: 44,
                    ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
      onRemove: widget.onRemove,
      onReplace: widget.onReplace,
      label: "New video selected",
    );
  }
}

// ── Network video preview (existing) ─────────────────────────────────────────
class _NetworkVideoPreview extends StatefulWidget {
  final String url;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const _NetworkVideoPreview({
    required this.url,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  State<_NetworkVideoPreview> createState() => _NetworkVideoPreviewState();
}

class _NetworkVideoPreviewState extends State<_NetworkVideoPreview> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoCard(
      child: _ready
          ? GestureDetector(
              onTap: () => _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _ctrl.value.aspectRatio,
                    child: VideoPlayer(_ctrl),
                  ),
                  if (!_ctrl.value.isPlaying)
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white70,
                      size: 44,
                    ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
      onRemove: widget.onRemove,
      onReplace: widget.onReplace,
      label: "Current video",
    );
  }
}

// ── Shared video card shell ───────────────────────────────────────────────────
Widget _videoCard({
  required Widget child,
  required VoidCallback onRemove,
  required VoidCallback onReplace,
  required String label,
}) {
  return Builder(
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160.h,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: child,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                ),
              ),
              TextButton.icon(
                onPressed: onReplace,
                icon: Icon(
                  Icons.swap_horiz,
                  size: 14.sp,
                  color: AppColor.primaryColor,
                ),
                label: Text(
                  "Change",
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 12.sp,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
              ),
              TextButton.icon(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  size: 14.sp,
                  color: Colors.red,
                ),
                label: Text(
                  "Remove",
                  style: TextStyle(color: Colors.red, fontSize: 12.sp),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

// ── Image tiles ───────────────────────────────────────────────────────────────
class _ExistingImageTile extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _ExistingImageTile({required this.imagePath, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 10.w),
          width: 110.w,
          height: 110.h,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
          child: Image.network(
            Global.getImageUrl(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewImageTile extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _NewImageTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 10.w),
          width: 110.w,
          height: 110.h,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r)),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
