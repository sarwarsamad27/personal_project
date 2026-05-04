import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:new_brand/models/productModel/addProduct_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class AddProductRepository {
  final NetworkApiServices apiServices = NetworkApiServices();

  Future<AddProductModel> addProduct({
    required String token,
    required String categoryId,
    required String name,
    String? description,
    List<File>? images,
    File? video,
    int? beforePrice,
    int? afterPrice,
    List<String>? size,
    List<String>? color,
    int? quantity,
    int? weightInGrams,
  }) async {
    try {
      final fields = <String, String>{
        'categoryId': categoryId,
        'name': name,
        if (description != null) 'description': description,
        if (beforePrice != null) 'beforeDiscountPrice': beforePrice.toString(),
        if (afterPrice != null) 'afterDiscountPrice': afterPrice.toString(),
        if (size != null && size.isNotEmpty) 'size': size.join(','),
        if (color != null && color.isNotEmpty) 'color': color.join(','),
        if (quantity != null) 'quantity': quantity.toString(),
        if (weightInGrams != null) 'weightInGrams': weightInGrams.toString(),
      };

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Global.CreateProduct),
      );
      final headers = await apiServices.getHeaders(isMultipart: true);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (final img in (images ?? [])) {
        request.files.add(
          await http.MultipartFile.fromPath('images', img.path),
        );
      }

      if (video != null) {
        final ext = video.path.split('.').last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            'video',
            video.path,
            contentType: MediaType('video', ext),
          ),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 300),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return AddProductModel.fromJson(decoded);
      }
      return AddProductModel(message: 'Server error: ${response.statusCode}');
    } catch (e) {
      return AddProductModel(message: 'Error: $e');
    }
  }
}
