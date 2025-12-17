import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:new_brand/models/orders/getMyOrders_model.dart';

class PdfProductTable {
  static pw.Widget build(Orders order) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 25),
        pw.Text("Order Details",
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange600)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            PdfHelpers.tableHeader(),
            ...order.products!.map((p) => PdfHelpers.productRow(p)),
            PdfHelpers.tableRow("Shipment", "Rs ${order.shipmentCharges}"),
            PdfHelpers.tableRow("Grand Total", "Rs ${order.grandTotal}"),
            PdfHelpers.tableRow("Order Date",
                PdfHelpers.formatDate(order.createdAt ?? "")),
          ],
        ),
      ],
    );
  }
}
