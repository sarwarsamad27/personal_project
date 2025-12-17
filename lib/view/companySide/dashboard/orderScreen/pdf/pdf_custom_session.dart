import 'package:new_brand/models/orders/getMyOrders_model.dart';
import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfCustomerSection {
  static pw.Widget build(Orders order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Text("Customer Information",
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange600)),
        pw.SizedBox(height: 8),
        PdfHelpers.info("Name", order.buyerDetails?.name ?? "N/A"),
        PdfHelpers.info("Email", order.buyerDetails?.email ?? "N/A"),
        PdfHelpers.info("Phone", order.buyerDetails?.phone ?? "N/A"),
        PdfHelpers.info("Address", order.buyerDetails?.address ?? "N/A"),
      ],
    );
  }
}
