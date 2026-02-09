// import 'package:flutter/material.dart';
// import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_custom_session.dart';
// import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_helper.dart';
// import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_header.dart';
// import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_product_table.dart';
// import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_qe_section.dart';
// import 'package:new_brand/view/companySide/dashboard/orderScreen/pdf/pdf_seller_section.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:new_brand/models/orders/getMyOrders_model.dart';
// import 'package:new_brand/resources/global.dart';
// import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
// import 'package:provider/provider.dart';

// class PdfInvoiceService {
//   Future<void> generateInvoice(
//     BuildContext context,
//     Orders order,
//   ) async {
//     final profileProvider =
//         Provider.of<ProfileFetchProvider>(context, listen: false);

//     if (profileProvider.profileData == null) {
//       await profileProvider.getProfileOnce();
//     }

//     final seller = profileProvider.profileData?.profile;

//     final pdf = pw.Document();

//     final shookooLogo =
//         await PdfHelpers.loadAssetImage("assets/images/shookoo_image.png");

//     final sellerImg = await PdfHelpers.loadNetworkImage(
//       "${Global.imageUrl}${seller?.image}",
//     );

//     final qr = await PdfQrSection.buildQrImage(order.sId ?? "");

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(28),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               PdfHeader.build(shookooLogo),
//               PdfCustomerSection.build(order),
//               PdfSellerSection.build(seller, sellerImg, shookooLogo),

//               // ✅ ALL PRODUCTS in one table
//               PdfProductTable.build(order),

//               PdfQrSection.build(qr),
//             ],
//           );
//         },
//       ),
//     );

//     // ✅ Single invoice per order
//     final fileId = order.sId;
//     await PdfHelpers.saveAndOpen(pdf, fileId!);
//   }
// }
