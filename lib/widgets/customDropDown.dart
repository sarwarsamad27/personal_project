import 'package:flutter/material.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:provider/provider.dart';

import '../../../resources/toast.dart';
import '../../../viewModel/providers/orderProvider/getDispatchedorder_provider.dart';
import '../../../viewModel/providers/orderProvider/order_provider.dart';
import '../../../viewModel/providers/orderProvider/pendingToDispatched_provider.dart';

class FancyStatusDropdown extends StatelessWidget {
  final dynamic order;

  const FancyStatusDropdown({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
        color: AppColor.primaryColor.withOpacity(0.25),
      ),
      child: DropdownButton<String>(
        value: order.status,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: AppColor.primaryColor,
        style: const TextStyle(color: Colors.white),
        items: ["Pending", "Dispatched"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (status) async {
          if (status == "Dispatched") {
            bool success = await context
                .read<PendingToDispatchedProvider>()
                .updateOrderStatus(orderId: order.sId!, status: "dispatched");

            if (success) {
              context.read<GetMyOrdersProvider>().updateStatusAndRefresh();
              context
                  .read<GetDispatchedOrderProvider>()
                  .fetchDispatchedOrders(isRefresh: true);

              AppToast.success("Order moved to dispatched");
            }
          }
        },
      ),
    );
  }
}
