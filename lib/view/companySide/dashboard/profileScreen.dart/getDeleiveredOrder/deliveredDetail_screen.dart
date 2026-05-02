import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/orders/getDeliveredOrder_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';

class DeliveredOrderDetailScreen extends StatelessWidget {
  final Orders order;

  const DeliveredOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Text("Detail", style: TextStyle(color: Colors.white)),
      ),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView(
            children: [
              /// BUYER INFO
              CustomAppContainer(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Buyer: ${order.buyerDetails?.name ?? ''}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Phone: ${order.buyerDetails?.phone ?? ''}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Address: ${order.buyerDetails?.address ?? ''}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              /// PRODUCTS
              ...order.products!.map(
                (p) => CustomAppContainer(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (p.selectedColor != null &&
                          p.selectedColor!.isNotEmpty) ...[
                        Text(
                          "Color: ${p.selectedColor?.join(', ') ?? ''}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                      if (p.selectedSize != null &&
                          p.selectedSize!.isNotEmpty) ...[
                        Text(
                          "Size: ${p.selectedSize?.join(', ') ?? ''}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                      Text(
                        "Qty: ${p.quantity}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Price: Rs. ${p.price}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              /// TOTAL
              CustomAppContainer(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white24),
                    Builder(
                      builder: (_) {
                        final shipment = order.shipmentCharges ?? 200;
                        final products = (order.grandTotal ?? 0) - shipment;
                        final platformFee = (products * 0.10).round();
                        final net = (products * 0.90).round();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Product Amount:      Rs. $products",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Platform Fee (10%):  - Rs. $platformFee",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Divider(color: Colors.white24),
                            Text(
                              "Net to You: Rs. $net",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "(90% of product price)",
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
