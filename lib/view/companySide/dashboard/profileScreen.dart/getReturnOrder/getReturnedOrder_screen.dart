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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GetReturnedOrderProvider>().fetchReturnedOrders(
        refresh: true,
      );
    });
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

        return ListView.separated(
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
                          "Order #${order.sId!.substring(0, 6)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.createdAt ?? '',
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
                          "Rs. ${order.grandTotal}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Returned",
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
