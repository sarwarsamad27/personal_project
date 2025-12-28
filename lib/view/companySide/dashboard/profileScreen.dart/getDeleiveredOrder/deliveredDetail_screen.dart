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
        title: const Text("Delivered Order Detail"),
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
                      Text(
                        "Color: ${p.selectedColor?.join(', ') ?? ''}",
                        style: const TextStyle(color: Colors.white70),
                      ),

                      Text(
                        "Size: ${p.selectedSize?.join(', ') ?? ''}",
                        style: const TextStyle(color: Colors.white70),
                      ),
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
                    Text(
                      "Shipment: Rs. ${order.shipmentCharges}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Grand Total: Rs. ${order.grandTotal}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
