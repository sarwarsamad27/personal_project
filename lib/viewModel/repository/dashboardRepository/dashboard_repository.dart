import 'package:new_brand/models/dashboard/dashboard_model.dart';
import 'package:new_brand/network/network_api_services.dart';
import 'package:new_brand/resources/global.dart';

class GetDashboardRepository {
  final NetworkApiServices apiServices = NetworkApiServices();
  final String apiUrl = Global.GetDashboardData;

  Future<DashboardDataModel> getDashboardData() async {
    final response =
        await apiServices.cachedGetApi('seller_dashboard', apiUrl);
    return DashboardDataModel.fromJson(response);
  }
}
