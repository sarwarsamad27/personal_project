import 'package:new_brand/models/productModel/getProductCategoryWise_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetProductsByStockRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetProductsByStock;

  Future<GetProductCategoryWiseModel> getProductsByStock({
    required String stockStatus,
    int page = 1,
    int limit = 20,
  }) async {
    final url = "$apiUrl?stockStatus=$stockStatus&page=$page&limit=$limit";
    final response = await apiServices.getApi(url);
    return GetProductCategoryWiseModel.fromJson(response);
  }
}
