import 'package:new_brand/models/orders/allOrders_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetAllOrdersAnyStatusRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetAllOrdersAnyStatus;

  Future<AllOrdersModel> getAllOrders({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url = "$apiUrl?page=$page&limit=$limit";
    if (startDate != null && endDate != null) {
      String iso(DateTime d) =>
          "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      url += "&startDate=${iso(startDate)}&endDate=${iso(endDate)}";
    }

    final response = await apiServices.getApi(url);
    return AllOrdersModel.fromJson(response);
  }
}
