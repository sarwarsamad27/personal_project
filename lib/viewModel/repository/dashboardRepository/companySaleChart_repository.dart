import 'package:new_brand/models/dashboard/companySaleChart_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetCompanySalesChartRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetCompanySalesChart;

  Future<CompanySalesChartModel> getCompanySalesChart({
    required String type,
    required String token,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var url = "$apiUrl?type=$type";
      if (startDate != null && endDate != null) {
        String iso(DateTime d) =>
            "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
        url += "&startDate=${iso(startDate)}&endDate=${iso(endDate)}";
      }

      final response = await apiServices.getApi(url);

      return CompanySalesChartModel.fromJson(response);
    } catch (e) {
      return CompanySalesChartModel(message: "Error: $e");
    }
  }
}
