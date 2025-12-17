import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfSellerSection {
  static pw.Widget build(
    profile,
    pw.MemoryImage? img,
    pw.MemoryImage placeholder,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Text(
          "Seller Information",
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue600,
          ),
        ),
        pw.SizedBox(height: 10),

        pw.SizedBox(height: 12),
        PdfHelpers.info("Name", profile?.name ?? "N/A"),
        PdfHelpers.info("Email", profile?.email ?? "N/A"),
        PdfHelpers.info("Phone", profile?.phone ?? "N/A"),
        PdfHelpers.info("Address", profile?.address ?? "N/A"),
        PdfHelpers.info("Description", profile?.description ?? "N/A"),
      ],
    );
  }
}
