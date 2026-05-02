import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/orders/getReturnedOrder_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';

class ReturnedOrderDetailScreen extends StatelessWidget {
  final Orders order;

  const ReturnedOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      appBar: AppBar( backgroundColor: AppColor.primaryColor,title: const Text("Returned Order Detail")),
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView(
            children: [
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
                      Text(
                        "Qty: ${p.quantity}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Size: ${p.selectedSize?.join(', ') ?? ''}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Color: ${p.selectedColor?.join(', ') ?? ''}",
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

              CustomAppContainer(
                padding: EdgeInsets.all(12.w),
                child: Builder(builder: (_) {
                  final productTotal = (order.products ?? []).fold<int>(
                    0,
                    (sum, p) => sum + ((p.price ?? 0) * (p.quantity ?? 1)),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ID: ${order.orderId ?? '-'}",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const Divider(color: Colors.white24),
                      Text(
                        "Product Amount: Rs. $productTotal",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Divider(color: Colors.white24),
                      const Text(
                        "Status: Returned",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Courier fee deducted from your wallet",
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
