import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/getDeleiveredOrder/deliveredDetail_screen.dart';
import 'package:new_brand/viewModel/providers/commissionProvider/commission_provider.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getDeliveredOrder_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/widgets/customContainer.dart';

class GetdeliveredorderScreen extends StatefulWidget {
  const GetdeliveredorderScreen({super.key});

  @override
  State<GetdeliveredorderScreen> createState() =>
      _GetdeliveredorderScreenState();
}

class _GetdeliveredorderScreenState extends State<GetdeliveredorderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final orderProvider = context.read<GetDeliveredOrderProvider>();
      if (orderProvider.orders.isEmpty) {
        orderProvider.fetchDeliveredOrders(refresh: false);
      }
      final commProvider = context.read<CommissionProvider>();
      if (!commProvider.hasFetched) {
        commProvider.fetchCommission();
      }
    });
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $hour:$minute $period';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GetDeliveredOrderProvider, CommissionProvider>(
      builder: (context, provider, commissionProvider, _) {
        if (provider.isLoading && provider.orders.isEmpty) {
          return SpinKitThreeBounce(color: AppColor.whiteColor, size: 30);
        }

        if (provider.orders.isEmpty) {
          return const Center(child: Text("No Delivered Orders"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.fetchDeliveredOrders(refresh: true);
            await commissionProvider.fetchCommission();
          },
          color: AppColor.primaryColor,
          child: ListView.separated(
            itemCount: provider.orders.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white24, height: 15.h),
            itemBuilder: (context, index) {
              final order = provider.orders[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveredOrderDetailScreen(order: order),
                    ),
                  );
                },
                child: CustomAppContainer(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderId ??
                                "Order #${order.orderId!.substring(0, 6)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(order.createdAt),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            () {
                              // 1. Prefer stored earning (Historical source of truth)
                              if (order.sellerEarning != null) {
                                return "Net: Rs. ${order.sellerEarning}";
                              }

                              // 2. Fallback for old orders (Before model update)
                              // If delivered before today, assume 10% was used if provider not fetched.
                              const defaultRate = 10.0;
                              final commissionRate =
                                  (commissionProvider.hasFetched
                                      ? commissionProvider.commissionPercent
                                      : defaultRate) /
                                  100;

                              final shipment = order.shipmentCharges ?? 200;
                              final products =
                                  (order.grandTotal ?? 0) - shipment;
                              final net = (products * (1 - commissionRate))
                                  .round();
                              return "Net: Rs. $net";
                            }(),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Delivered",
                            style: TextStyle(color: Colors.green, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
