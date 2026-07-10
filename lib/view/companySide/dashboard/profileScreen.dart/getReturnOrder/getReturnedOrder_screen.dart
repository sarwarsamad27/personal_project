import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/view/companySide/dashboard/profileScreen.dart/getReturnOrder/returnOrderDetail_screen.dart';
import 'package:new_brand/viewModel/providers/orderProvider/getReturnedOrder_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_brand/widgets/customContainer.dart';

class GetReturnedorderScreen extends StatefulWidget {
  const GetReturnedorderScreen({super.key});

  @override
  State<GetReturnedorderScreen> createState() => _GetReturnedorderScreenState();
}

class _GetReturnedorderScreenState extends State<GetReturnedorderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<GetReturnedOrderProvider>();
      if (provider.orders.isEmpty) {
        provider.fetchReturnedOrders(refresh: false);
      }
    });
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final nearBottom = position.pixels >= position.maxScrollExtent - 200;
      if (!nearBottom) return;

      final provider = context.read<GetReturnedOrderProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchReturnedOrders();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return Consumer<GetReturnedOrderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.orders.isEmpty) {
          return SpinKitThreeBounce(color: AppColor.whiteColor, size: 30);
        }

        if (provider.orders.isEmpty) {
          return const Center(child: Text("No Returned Orders"));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchReturnedOrders(refresh: true),
          color: AppColor.primaryColor,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: provider.orders.length + (provider.hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white24, height: 15.h),
            itemBuilder: (context, index) {
              if (index == provider.orders.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: AppColor.whiteColor,
                      size: 24,
                    ),
                  ),
                );
              }

              final order = provider.orders[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReturnedOrderDetailScreen(order: order),
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
                                "Order #${order.sId!.substring(0, 6)}",
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
                          const Text(
                            "Returned",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "Courier fee deducted",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
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
