class AnalyzeStoreModel {
  String? description;
  String? message;

  AnalyzeStoreModel({this.description, this.message});

  AnalyzeStoreModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    message = json['message'];
  }
}
