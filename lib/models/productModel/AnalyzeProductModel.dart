class AnalyzeProductModel {
  String? name;
  String? description;
  String? message;

  AnalyzeProductModel({this.name, this.description, this.message});

  AnalyzeProductModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    message = json['message'];
  }
}