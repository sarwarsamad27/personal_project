import 'package:flutter/material.dart';

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
      'image': 'https://picsum.photos/id/1011/400/300',
    },
    {
      'name': 'Casual Sneakers',
      'price': '₹2,199',
      'image': 'https://picsum.photos/id/1012/400/300',
    },
    {
      'name': 'Formal Shoes',
      'price': '₹4,999',
      'image': 'https://picsum.photos/id/1013/400/300',
    },
    {
      'name': 'Sports Sandals',
      'price': '₹1,299',
      'image': 'https://picsum.photos/id/1015/400/300',
    },
    {
      'name': 'High Tops',
      'price': '₹3,799',
      'image': 'https://picsum.photos/id/1016/400/300',
    },
    {
      'name': 'Loafers',
      'price': '₹2,899',
      'image': 'https://picsum.photos/id/1018/400/300',
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

                // dark gradient for readable text
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
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
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                    return ProductCard(
                      name: product['name']!,
                      price: product['price']!,
                      imageUrl: product['image']!,
                      onTap: () {
                        // handle product tap
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped: ${product['name']}')),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // product image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),

            // name & price
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// To use this screen:
// Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryProductsScreen()));
