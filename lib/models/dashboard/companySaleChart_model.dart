class CompanySalesChartModel {
  String? message;
  Data? data;

  CompanySalesChartModel({this.message, this.data});

  CompanySalesChartModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? type;
  // Nullable entries — a `null` label/value is an unfilled placeholder slot
  // (custom date range shorter than 7 periods): "no date assigned", not a
  // zero-sales period.
  List<String?>? labels;
  List<int?>? values;

  Data({this.type, this.labels, this.values});

  Data.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    labels = (json['labels'] as List?)?.map((e) => e as String?).toList();
    values = (json['values'] as List?)
        ?.map((e) => (e as num?)?.toInt())
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['labels'] = labels;
    data['values'] = values;
    return data;
  }
}
