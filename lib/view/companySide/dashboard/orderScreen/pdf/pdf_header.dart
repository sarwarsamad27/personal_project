import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' show PdfColors;

class PdfHeader {
  static pw.Widget build(pw.MemoryImage logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(
          width: 75,
          height: 75,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: PdfColors.orange600, width: 3),
          ),
          child: pw.ClipOval(child: pw.Image(logo)),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "SHOOKOO",
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange600,
              ),
            ),
            pw.Text(
              "Delivering Quality With Every Order",
              style: pw.TextStyle(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
