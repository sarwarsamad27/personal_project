import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
class PdfHelpers {
  static pw.Widget info(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("$label:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(value),
          ],
        ),
      );

  static pw.TableRow tableRow(String label, String value) => pw.TableRow(
        children: [
          pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(label,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(
              padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
        ],
      );

  static pw.TableRow tableHeader() => pw.TableRow(
        children: [
          _cell("Product", true),
          _cell("Color", true),
          _cell("Size", true),
          _cell("Qty", true),
          _cell("Price", true),
        ],
      );

  static pw.TableRow productRow(product) => pw.TableRow(
        children: [
          _cell(product.name ?? ""),
          _cell((product.selectedColor ?? []).join(", ")),
          _cell((product.selectedSize ?? []).join(", ")),
          _cell(product.quantity.toString()),
          _cell("Rs ${product.totalPrice}"),
        ],
      );

  static pw.Widget _cell(String text, [bool bold = false]) => pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );

  static Future<pw.MemoryImage> loadAssetImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  static Future<pw.MemoryImage?> loadNetworkImage(String url) async {
    try {
      final data = await NetworkAssetBundle(Uri.parse(url)).load("");
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveAndOpen(pw.Document pdf, String id) async {
    final dir = await getExternalStorageDirectory();
    final file = File("${dir!.path}/invoice_$id.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static String formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return iso;
    }
  }
}
