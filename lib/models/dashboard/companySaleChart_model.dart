class CompanySalesChartModel {
  String? message;
  Data? data;

  CompanySalesChartModel({this.message, this.data});

  CompanySalesChartModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? type;
  List<String>? labels;
  List<int>? values;

  Data({this.type, this.labels, this.values});

  Data.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    labels = json['labels'].cast<String>();
    values = json['values'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['labels'] = this.labels;
    data['values'] = this.values;
    return data;
  }
}
