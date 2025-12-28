import 'package:new_brand/models/dashboard/companySaleChart_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetCompanySalesChartRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetCompanySalesChart;

  /// Delete category by Id
  Future<CompanySalesChartModel> getCompanySalesChart({
    required String type,
    required String token,
  }) async {
    try {
      final url = "$apiUrl?type=$type";

      final response = await apiServices.getApi(url);

      return CompanySalesChartModel.fromJson(response);
    } catch (e) {
      return CompanySalesChartModel(message: "Error: $e");
    }
  }
}
