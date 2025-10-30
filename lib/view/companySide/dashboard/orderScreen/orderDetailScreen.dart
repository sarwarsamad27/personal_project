import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color _getStatusColor(String status) {
      switch (status) {
        case 'Pending':
          return Colors.orangeAccent;
        case 'Shipped':
          return Colors.blueAccent;
        case 'Delivered':
          return Colors.greenAccent;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      body: CustomBgContainer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Details",
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.h),

                CustomAppContainer(
                  padding: EdgeInsets.all(24.w),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("Order ID", order['orderId']),
                      _buildRow("Product", order['productName']),
                      _buildRow("Customer", order['customerName']),
                      _buildRow("Quantity", order['quantity'].toString()),
                      _buildRow("Total Price", "Rs ${order['totalPrice']}"),
                      _buildRow("Date", order['date']),
                      _buildRow("Payment", order['paymentMethod']),
                      _buildRow("Address", order['address']),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Status: ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order['status'],
                              ).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: _getStatusColor(order['status']),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              order['status'],
                              style: TextStyle(
                                color: _getStatusColor(order['status']),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
