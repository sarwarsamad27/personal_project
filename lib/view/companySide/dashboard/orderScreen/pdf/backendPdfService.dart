// lib/view/companySide/dashboard/orderScreen/pdf/backend_pdf_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';

class BackendPdfService {
  /// ✅ Download and open invoice PDF from backend
  Future<void> downloadAndOpenInvoice(BuildContext context, String orderId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      // ✅ Get auth token
      final token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found");
      }

      // ✅ Build URL
      final url = Uri.parse("${Global.generateInvoicePdf}?orderId=$orderId");

      print("📥 Downloading invoice PDF from: $url");

      // ✅ Make request
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      print("📊 Response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        String errorMessage = "Failed to generate PDF";
        
        try {
          // Try to parse error message from JSON response
          final errorBody = response.body;
          if (errorBody.contains('message')) {
            // Extract message if JSON
            errorMessage = errorBody;
          }
        } catch (_) {
          errorMessage = "Failed to generate PDF (${response.statusCode})";
        }
        
        throw Exception(errorMessage);
      }

      // ✅ Check if response is actually a PDF
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('pdf') && response.bodyBytes.length < 100) {
        throw Exception("Invalid PDF response from server");
      }

      // ✅ Save PDF to device storage
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/invoice_$orderId.pdf";
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes, flush: true);

      print("✅ PDF saved to: $filePath");
      print("📄 PDF size: ${response.bodyBytes.length} bytes");

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // ✅ Open PDF
      final result = await OpenFilex.open(filePath);
      
      print("📱 Open result: ${result.type} - ${result.message}");

      if (result.type != ResultType.done) {
        // If default PDF viewer failed, show success message anyway
        if (context.mounted) {
          AppToast.success("PDF saved to: Downloads/invoice_$orderId.pdf");
        }
      }

    } catch (error) {
      print("❌ PDF Download Error: $error");
      
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show error message
        AppToast.error(
          error.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  /// ✅ Check if PDF already exists locally
  Future<bool> pdfExists(String orderId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/invoice_$orderId.pdf";
      final file = File(filePath);
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  /// ✅ Open existing PDF
  Future<void> openExistingPdf(String orderId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/invoice_$orderId.pdf";
      await OpenFilex.open(filePath);
    } catch (error) {
      print("❌ Error opening PDF: $error");
      throw Exception("Failed to open PDF");
    }
  }

  /// ✅ Delete PDF
  Future<void> deletePdf(String orderId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/invoice_$orderId.pdf";
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
        print("🗑️ PDF deleted: $filePath");
      }
    } catch (error) {
      print("❌ Error deleting PDF: $error");
    }
  }
}