// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:qr_flutter/qr_flutter.dart';

// class PdfQrSection {
//   static Future<Uint8List> buildQrImage(String orderId) async {
//     final qrUrl = "https://shookoo.com/orders/$orderId";

//     final qr = QrValidator.validate(
//       data: qrUrl,
//       version: QrVersions.auto,
//       errorCorrectionLevel: QrErrorCorrectLevel.H,
//     ).qrCode!;

//     final painter = QrPainter.withQr(qr: qr, color: Colors.black);
//     final img = await painter.toImageData(300);
//     return img!.buffer.asUint8List();
//   }

//   static pw.Widget build(Uint8List img) {
//     return pw.Center(
//       child: pw.Column(
//         children: [
//           pw.SizedBox(height: 30),
//           pw.Text("Scan to view order",
//               style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
//           pw.SizedBox(height: 10),
//           pw.Image(pw.MemoryImage(img), width: 110, height: 110),
//         ],
//       ),
//     );
//   }
// }
