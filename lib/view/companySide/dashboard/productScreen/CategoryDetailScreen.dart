import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/addProductScreen.dart';
import 'package:new_brand/view/companySide/dashboard/productScreen/productCategory/addProduct/productDetail/productDetailScreen.dart';
import 'package:new_brand/widgets/productCard.dart';

// A standalone Flutter screen that shows:
// - Top half: a product category image (hero banner)
// - Bottom half: a scrollable list of product cards (grid)
// This is ready to paste into your project. Replace image URLs and product data as needed.

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({Key? key}) : super(key: key);

  // Example product data
  final List<Map<String, String>> products = const [
    {
      'name': 'Running Shoes',
      'price': '₹3,499',
      'image':
          'https://thumbs.dreamstime.com/b/beautiful-rain-forest-ang-ka-nature-trail-doi-inthanon-national-park-thailand-36703721.jpg',
    },
    {
      'name': 'Casual Sneakers',
      'price': '₹2,199',
      'image':
          'https://cdn.pixabay.com/photo/2025/04/28/19/59/female-model-9565629_640.jpg',
    },
    {
      'name': 'Formal Shoes',
      'price': '₹4,999',
      'image':
          'https://bkacontent.com/wp-content/uploads/2016/06/Depositphotos_31146757_l-2015.jpg',
    },
    {
      'name': 'Sports Sandals',
      'price': '₹1,299',
      'image':
          'https://image-processor-storage.s3.us-west-2.amazonaws.com/images/3cf61c1011912a2173ea4dfa260f1108/halo-of-neon-ring-illuminated-in-the-stunning-landscape-of-yosemite.jpg',
    },
    {
      'name': 'High Tops',
      'price': '₹3,799',
      'image':
          'https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/14235/production/_100058428_mediaitem100058424.jpg',
    },
    {
      'name': 'Loafers',
      'price': '₹2,899',
      'image':
          'https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/14235/production/_100058428_mediaitem100058424.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final halfHeight = media.height * 0.5; // top half for category image

    return Scaffold(
      body: Column(
        children: [
          // Top half: category image with overlay text
          SizedBox(
            height: halfHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Replace this NetworkImage with your asset if needed
                Image.network(
                  'https://picsum.photos/id/1005/900/800',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),

                // category title and short description
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Shoes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom half: scrollable products grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                    onTap: () {},
                    child: ProductCard(
                      name: product['name']!,
                      price: product['price']!,
                      imageUrl: product['image']!,
                      saveText: "Save Rs.1000",
                      originalPrice: "Rs. 5,000",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              imageUrls: [
                                'https://images.unsplash.com/photo-1526779259212-939e64788e3c?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZnJlZSUyMGltYWdlc3xlbnwwfHwwfHx8MA%3D%3D&fm=jpg&q=60&w=3000',
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNubLmqdOK9pZWU-2IiD20cuSIdUUDi9-NvQ&s',
                                'https://cdn.pixabay.com/photo/2016/11/21/06/53/beautiful-natural-image-1844362_640.jpg',
                              ],
                              name: 'Nike Air Zoom Pegasus',
                              description:
                                  'Experience next-level comfort and performance with the Nike Air Zoom Pegasus. Designed for everyday runners with responsive cushioning and lightweight design.',
                              color: 'Black',
                              size: '42',
                              price: 'PKR 11,999',
                            ),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped: ${product['name']}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 70.h,
        width: 70.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor,
              AppColor.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductScreen()),
            );
          },
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

// To use this screen:
// Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryProductsScreen()));
