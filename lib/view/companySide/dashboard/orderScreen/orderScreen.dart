import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/orderDetailScreen.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = [
      {
        'orderId': '#A001',
        'customerName': 'Ali Khan',
        'productName': 'Premium Shoes',
        'quantity': 2,
        'totalPrice': 9998,
        'status': 'Pending',
        'address': 'House 23, Street 12, Karachi',
        'paymentMethod': 'Cash on Delivery',
        'date': '29 Oct 2025',
      },
      {
        'orderId': '#A002',
        'customerName': 'Sara Malik',
        'productName': 'Casual Hoodie',
        'quantity': 1,
        'totalPrice': 4999,
        'status': 'Dispatched',
        'address': 'Block H, DHA Phase 5, Lahore',
        'paymentMethod': 'Credit Card',
        'date': '28 Oct 2025',
      },
      {
        'orderId': '#A003',
        'customerName': 'Usman Tariq',
        'productName': 'Leather Jacket',
        'quantity': 1,
        'totalPrice': 8499,
        'status': 'Delivered',
        'address': 'Street 9, Islamabad',
        'paymentMethod': 'JazzCash',
        'date': '26 Oct 2025',
      },
      {
        'orderId': '#A004',
        'customerName': 'saif hussain',
        'productName': 'shirt',
        'quantity': 1,
        'totalPrice': 8499,
        'status': 'Delivered',
        'address': 'Street 9, Islamabad',
        'paymentMethod': 'JazzCash',
        'date': '26 Oct 2025',
      },
      {
        'orderId': '#A004',
        'customerName': 'gufran Tariq',
        'productName': ' Jacket',
        'quantity': 1,
        'totalPrice': 8499,
        'status': 'Pending',
        'address': 'Street 9, Karachi',
        'paymentMethod': 'JazzCash',
        'date': '21 Oct 2025',
      },
      {
        'orderId': '#A005',
        'customerName': 'Usman taha',
        'productName': 'Leather',
        'quantity': 1,
        'totalPrice': 8499,
        'status': 'Delivered',
        'address': 'Street 9, lahore',
        'paymentMethod': 'JazzCash',
        'date': '24 Oct 2025',
      },
      {
        'orderId': '#A006',
        'customerName': 'siddique',
        'productName': 'Shoes',
        'quantity': 1,
        'totalPrice': 8499,
        'status': 'Dispatched',
        'address': 'Street 9, sialkot',
        'paymentMethod': 'JazzCash',
        'date': '26 Oct 2025',
      },
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case 'Pending':
          return Colors.red;
        case 'Dispatched':
          return Colors.blueAccent;
        case 'Delivered':
          return Colors.greenAccent;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      child: CustomAppContainer(
                        padding: EdgeInsets.all(20.w),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order['orderId'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                      order['status'],
                                    ).withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: getStatusColor(order['status']),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    order['status'],
                                    style: TextStyle(
                                      color: getStatusColor(order['status']),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            Text(
                              order['productName'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),

                            Text(
                              "Customer: ${order['customerName']}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Quantity: ${order['quantity']}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  "Rs ${order['totalPrice']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
