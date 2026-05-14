import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/orders/getDeliveredOrder_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/viewModel/providers/commissionProvider/commission_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:provider/provider.dart';

class DeliveredOrderDetailScreen extends StatefulWidget {
  final Orders order;

  const DeliveredOrderDetailScreen({super.key, required this.order});

  @override
  State<DeliveredOrderDetailScreen> createState() =>
      _DeliveredOrderDetailScreenState();
}

class _DeliveredOrderDetailScreenState
    extends State<DeliveredOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<CommissionProvider>();
      if (!p.hasFetched) {
        p.fetchCommission();
      }
    });
  }

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
                      "Customer: ${widget.order.buyerDetails?.name ?? ''}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Phone: ${widget.order.buyerDetails?.phone ?? ''}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Address: ${widget.order.buyerDetails?.address ?? ''}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              /// PRODUCTS
              ...widget.order.products!.map(
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
                    Consumer<CommissionProvider>(
                      builder: (context, commissionProvider, _) {
                        // 1. Check if we have stored historical data
                        final hasHistory = widget.order.sellerEarning != null;

                        final double commissionPct;
                        final int platformFee;
                        final int net;

                        final shipment = widget.order.shipmentCharges ?? 200;
                        final products =
                            (widget.order.grandTotal ?? 0) - shipment;

                        if (hasHistory) {
                          commissionPct = (widget.order.commissionRate ?? 10)
                              .toDouble();
                          net = widget.order.sellerEarning!;
                          platformFee = products - net;
                        } else {
                          // Fallback for old orders
                          commissionPct = commissionProvider.hasFetched
                              ? commissionProvider.commissionPercent
                              : 10.0;
                          final rate = commissionPct / 100;
                          platformFee = (products * rate).round();
                          net = (products * (1 - rate)).round();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Product Amount:      Rs. $products",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            if (!hasHistory && commissionProvider.isLoading)
                              const LinearProgressIndicator(
                                minHeight: 2,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white24,
                                ),
                              )
                            else
                              Text(
                                "Platform Fee (${commissionPct.toStringAsFixed(0)}%):  - Rs. $platformFee",
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
                              "(${(100 - commissionPct).toStringAsFixed(0)}% of product price)",
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
