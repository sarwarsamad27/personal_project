import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/productCard.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailScreen extends StatefulWidget {
  final List<String> imageUrls;
  final String name;
  final String description;
  final String color;
  final String size;
  final String price;

  const ProductDetailScreen({
    super.key,
    required this.imageUrls,
    required this.name,
    required this.description,
    required this.color,
    required this.size,
    required this.price,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();

  // for edit modal
  Future<File?> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) return File(picked.path);
    return null;
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text(
          "Are you sure you want to delete this product permanently?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Product deleted successfully!")),
              );
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProduct() {
    // Initial product values
    String oldName = widget.name;
    String oldPrice = widget.price.replaceAll("PKR ", "");
    String oldDescription = widget.description;
    String oldColor = widget.color;
    String oldSize = widget.size;
    List<String> oldImages = List<String>.from(widget.imageUrls);

    // Controllers
    final nameController = TextEditingController(text: oldName);
    final priceController = TextEditingController(text: oldPrice);
    final descriptionController = TextEditingController(text: oldDescription);
    final colorController = TextEditingController(text: oldColor);
    final sizeController = TextEditingController(text: oldSize);

    // Mutable lists for image edits
    List<File> newImages = [];
    List<String> existingImages = List<String>.from(oldImages);

    bool isChanged = false;

    Future<void> _pickImages(StateSetter setModalState) async {
      if (existingImages.length + newImages.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can only upload up to 5 images")),
        );
        return;
      }

      final picked = await ImagePicker().pickMultiImage();
      if (picked.isNotEmpty) {
        final selected = picked.map((x) => File(x.path)).toList();
        setModalState(() {
          newImages.addAll(
            selected.take(5 - (existingImages.length + newImages.length)),
          );
          isChanged = true;
        });
      }
    }

    void _removeExistingImage(int index, StateSetter setModalState) {
      setModalState(() {
        existingImages.removeAt(index);
        isChanged = true;
      });
    }

    void _removeNewImage(int index, StateSetter setModalState) {
      setModalState(() {
        newImages.removeAt(index);
        isChanged = true;
      });
    }

    void _checkChanges(StateSetter setModalState) {
      final nameChanged = nameController.text.trim() != oldName;
      final priceChanged = priceController.text.trim() != oldPrice;
      final descChanged = descriptionController.text.trim() != oldDescription;
      final colorChanged = colorController.text.trim() != oldColor;
      final sizeChanged = sizeController.text.trim() != oldSize;
      setModalState(() {
        isChanged =
            nameChanged ||
            priceChanged ||
            descChanged ||
            colorChanged ||
            sizeChanged ||
            newImages.isNotEmpty ||
            existingImages.length != oldImages.length;
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
          backgroundColor: Colors.transparent,
          child: CustomAppContainer(
            color: Colors.white70,
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                nameController.addListener(() => _checkChanges(setModalState));
                priceController.addListener(() => _checkChanges(setModalState));
                descriptionController.addListener(
                  () => _checkChanges(setModalState),
                );
                colorController.addListener(() => _checkChanges(setModalState));
                sizeController.addListener(() => _checkChanges(setModalState));

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

                      // ---------- IMAGE SECTION ----------
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
                            // Existing images
                            ...List.generate(existingImages.length, (i) {
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
                                    child: Image.network(
                                      existingImages[i],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeExistingImage(
                                        i,
                                        setModalState,
                                      ),
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

                            // Newly added images
                            ...List.generate(newImages.length, (i) {
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
                                    child: Image.file(
                                      newImages[i],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _removeNewImage(i, setModalState),
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

                            // Add button
                            if (existingImages.length + newImages.length < 5)
                              GestureDetector(
                                onTap: () => _pickImages(setModalState),
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

                      // ---------- EDITABLE FIELDS ----------
                      CustomTextField(
                        controller: nameController,
                        headerText: "Product Name",
                        hintText: "Enter product name",
                        prefixIcon: Icons.edit,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: priceController,
                        headerText: "Price",
                        hintText: "Enter price (PKR)",
                        prefixIcon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: descriptionController,
                        headerText: "Description",
                        hintText: "Write description",
                        height: 100.h,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: colorController,
                        headerText: "Color",
                        hintText: "Enter product color",
                        prefixIcon: Icons.palette_outlined,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: sizeController,
                        headerText: "Size",
                        hintText: "Enter available size",
                        prefixIcon: Icons.straighten,
                      ),

                      SizedBox(height: 25.h),

                      // ---------- BUTTONS ----------
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
                              opacity: isChanged ? 1.0 : 0.5,
                              child: CustomButton(
                                text: "Update",
                                onTap: () {
                                  isChanged
                                      ? () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Product updated successfully!",
                                              ),
                                            ),
                                          );
                                        }
                                      : null;
                                },
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final relatedProducts = [
      {
        'name': 'Running Shoes',
        'price': 'PKR 4,999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Sneakers',
        'price': 'PKR 6,499',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
      {
        'name': 'Sports Jacket',
        'price': 'PKR 8,999',
        'imageUrl':
            'https://i.pinimg.com/736x/60/a6/e2/60a6e2b0776d1d6735fce5ae7dc9b175.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Product Image Carousel ----------
                SizedBox(
                  height: 0.45.sh,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24.r),
                              bottomRight: Radius.circular(24.r),
                            ),
                            child: Image.network(
                              widget.imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 16.h,
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: widget.imageUrls.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: Colors.black,
                            dotColor: Colors.grey[400]!,
                            dotHeight: 8.h,
                            dotWidth: 8.w,
                            spacing: 6.w,
                          ),
                        ),
                      ),

                      // Back Button
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      // ---------- Edit / Delete Buttons ----------
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _editProduct,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: AppColor.primaryColor,
                                  size: 22,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            GestureDetector(
                              onTap: _deleteProduct,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- Product Details ----------
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 18.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.price,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          _buildDetailChip('Color: ${widget.color}'),
                          SizedBox(width: 8.w),
                          _buildDetailChip('Size: ${widget.size}'),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- Related Products ----------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    "Related Products",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  height: 250.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: relatedProducts.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) {
                      final item = relatedProducts[index];
                      return SizedBox(
                        width: 160.w,
                        child: ProductCard(
                          name: item['name']!,
                          price: item['price']!,
                          imageUrl: item['imageUrl']!,
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
      ),
    );
  }
}
