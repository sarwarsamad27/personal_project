import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_invoice_serivce.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';

class OrderDetailScreen extends StatelessWidget {
  final Orders order;
  const OrderDetailScreen({super.key, required this.order});

 

  @override
  Widget build(BuildContext context) {
    final product = order.products![0];

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
                      _buildRow("Order ID", order.sId ?? ""),
                      _buildRow("Product", product.name ?? ""),
                      _buildRow(
                        "Color",
                        (product.selectedColor ?? []).join(", "),
                      ),
                      _buildRow(
                        "Size",
                        (product.selectedSize ?? []).join(", "),
                      ),

                      _buildRow("Customer", order.buyerDetails?.name ?? ""),
                      _buildRow("Quantity", product.quantity.toString()),
                      _buildRow("Total Price", "Rs ${order.grandTotal}"),
                      _buildRow("Date", formatDate(order.createdAt ?? "")),
                      _buildRow("Payment", "Cash on Delivery"),
                      _buildRow(
                        "Address",
                        order.buyerDetails?.address ?? "N/A",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                CustomButton(
                  text: "Generate Invoice PDF",
                  onTap: () => PdfInvoiceService().generateInvoice(context, order),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.day.toString().padLeft(2, '0')} "
          "${_monthName(date.month)} "
          "${date.year} - ${_formatTime(date)}";
    } catch (e) {
      return isoDate;
    }
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    String period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12;
    if (hour == 0) hour = 12;
    String minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
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
