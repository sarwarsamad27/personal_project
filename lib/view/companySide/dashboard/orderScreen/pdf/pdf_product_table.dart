import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:new_brand/models/orders/getMyOrders_model.dart';

class PdfProductTable {
  static pw.Widget build(Orders order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 25),
        pw.Text(
          "Order Details",
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.orange600,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            PdfHelpers.tableHeader(),

            // ✅ Loop through all products
            ...order.products!.map((product) => PdfHelpers.productRow(product)),

            // ✅ Shipment charges
            PdfHelpers.tableRow(
              "Shipment",
              "Rs ${order.shipmentCharges ?? 0}",
            ),

            // ✅ Grand total = all products + shipment
            PdfHelpers.tableRow(
              "Grand Total",
              "Rs ${order.products!.fold(0, (sum, p) => sum + (p.totalPrice ?? 0)) + (order.shipmentCharges ?? 0)}",
            ),

            PdfHelpers.tableRow(
              "Order Date",
              PdfHelpers.formatDate(order.createdAt ?? ""),
            ),
          ],
        ),
      ],
    );
  }
}
