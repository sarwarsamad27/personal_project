

import 'dart:developer';

import 'package:new_brand/models/categoryModel/getCategory_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetCategoryRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetCategory;
  Future<GetCategoryModel> getCategory() async {
    final response = await apiServices.getApi(apiUrl);
    log(response.toString());

    return GetCategoryModel.fromJson(response);
  }
}
