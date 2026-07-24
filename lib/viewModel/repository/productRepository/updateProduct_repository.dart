import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:new_brand/models/productModel/editProduct_model.dart';
import 'package:new_brand/network/multipart_progress.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class UpdateProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<UpdateProductModel> updateProduct({
    required String productId,
    required String token,
    required String name,
    required String description,
    required int afterDiscountPrice,
    required int beforeDiscountPrice,
    required List<String> size,
    required List<String> color,
    required List<String> keepImages,
    required List<String> deleteImages,
    required int quantity,
    required int weightInGrams,
    required List<File> images,
    File? video,
    bool removeVideo = false,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final fields = <String, String>{
        'productId': productId,
        'name': name,
        'description': description,
        'afterDiscountPrice': afterDiscountPrice.toString(),
        'beforeDiscountPrice': beforeDiscountPrice.toString(),
        'size': size.join(','),
        'color': color.join(','),
        'quantity': quantity.toString(),
        'weightInGrams': weightInGrams.toString(),
        'keepImages': keepImages.join(','),
        'deleteImages': deleteImages.join(','),
        if (removeVideo) 'removeVideo': 'true',
      };

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(Global.UpdateSingleProduct),
      );
      final headers = await apiServices.getHeaders(isMultipart: true);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (final img in images) {
        request.files.add(await http.MultipartFile.fromPath('images', img.path));
      }

      if (video != null) {
        final ext = video.path.split('.').last.toLowerCase();
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          video.path,
          contentType: MediaType('video', ext),
        ));
      }

      final streamed = onProgress != null
          ? await sendMultipartWithProgress(
              request,
              onProgress: onProgress,
              timeout: const Duration(seconds: 300),
            )
          : await request.send().timeout(const Duration(seconds: 300));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return UpdateProductModel.fromJson(decoded);
      }
      return UpdateProductModel(message: 'Server error: ${response.statusCode}');
    } catch (e) {
      return UpdateProductModel(message: 'Error: $e');
    }
  }
}
