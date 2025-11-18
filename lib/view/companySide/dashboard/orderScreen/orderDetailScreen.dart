import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

  Future<void> _generateInvoice(BuildContext context) async {
    if (!await Permission.storage.request().isGranted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Storage permission required to save PDF")),
  );
  return;
}

    final pdf = pw.Document();

    // 🟠 Load Shookoo Logo
    final shookooLogo = await pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/shookoo_image.png',
      )).buffer.asUint8List(),
    );

    // 🟢 Optional Product/Brand Logo
    pw.MemoryImage? productLogo;
    try {
      productLogo = await pw.MemoryImage(
        (await rootBundle.load(
          'assets/images/product_logo.png',
        )).buffer.asUint8List(),
      );
    } catch (_) {
      productLogo = null;
    }

    // 🔵 Generate QR Code Image (Link to order detail)
    final qrUrl = "https://shookoo.com/orders/${order['orderId']}";
    final qrImage = await _generateQrCode(qrUrl);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 🟠 Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      width: 70,
                      height: 70,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(
                          color: PdfColors.orange,
                          width: 2,
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.ClipOval(child: pw.Image(shookooLogo)),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "SHOOKOO",
                          style: pw.TextStyle(
                            fontSize: 26,
                            color: PdfColors.orange600,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "Delivering Quality with Every Order",
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.orange300, thickness: 1),

                // 🧾 Invoice Title
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "INVOICE",
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      "#${order['orderId']}",
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),

                // 📋 Customer Info
                pw.SizedBox(height: 20),
                pw.Text(
                  "Customer Information",
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: PdfColors.orange600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                _infoText("Name", order['customerName'] ?? "N/A"),
                _infoText("Mobile", order['customerPhone'] ?? "0300-0000000"),
                _infoText(
                  "Email",
                  order['customerEmail'] ?? "customer@shookoo.com",
                ),
                _infoText("Address", order['address'] ?? "Not Provided"),

                // 🏪 Seller Info
                pw.SizedBox(height: 15),
                pw.Text(
                  "Seller / Brand Information",
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: PdfColors.orange600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (productLogo != null)
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.ClipOval(child: pw.Image(productLogo!)),
                      ),
                    pw.SizedBox(width: 8),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          order['sellerName'] ?? "Shookoo Official",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        pw.Text(
                          order['sellerEmail'] ?? "support@shookoo.com",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          order['sellerPhone'] ?? "+92 300 1112233",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          order['Address'] ?? "Karachi, Pakistan",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                // 🧾 Order Details Table
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 0.8,
                  ),
                  children: [
                    _tableRow("Product", order['productName']),
                    _tableRow("Quantity", order['quantity'].toString()),
                    _tableRow("Total Price", "Rs ${order['totalPrice']}"),
                    _tableRow("Payment", "Cash on Delivery"),
                    _tableRow("Order Date", order['date']),
                  ],
                ),

                // 📦 QR Code Section
                pw.SizedBox(height: 25),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "Scan to view order details",
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Image(
                        pw.MemoryImage(qrImage),
                        width: 100,
                        height: 100,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        qrUrl,
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.blue600,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 25),
                pw.Divider(color: PdfColors.grey300),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "Thank you for shopping with SHOOKOO!",
                        style: pw.TextStyle(
                          color: PdfColors.orange600,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "We appreciate your business!",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // 📁 Save + Open PDF
    final dir = await getExternalStorageDirectory();
final downloads = Directory("/storage/emulated/0/Download");
final file = File("${downloads.path}/invoice_${order['orderId']}.pdf");

    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  // 🔧 Generate QR Code as Image Bytes
  Future<Uint8List> _generateQrCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(qr: qrCode, color: Colors.black);
    final image = await painter.toImageData(300);
    return image!.buffer.asUint8List();
  }

  // 📋 Helper Widgets
  pw.Widget _infoText(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          "$label:",
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(value, style: const pw.TextStyle(color: PdfColors.black)),
      ],
    ),
  );

  pw.TableRow _tableRow(String label, String value) => pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
    ],
  );

  // 🖥 UI
  @override
  Widget build(BuildContext context) {
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
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 14.h,
                      ),
                    ),
                    icon: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Generate Invoice PDF",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _generateInvoice(context),
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
