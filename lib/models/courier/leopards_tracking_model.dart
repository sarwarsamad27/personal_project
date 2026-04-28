class LeopardsTrackingModel {
  final String? status;
  final String? trackDate;
  final String? trackTime;
  final String? trackLocation;

  LeopardsTrackingModel({
    this.status,
    this.trackDate,
    this.trackTime,
    this.trackLocation,
  });

  factory LeopardsTrackingModel.fromJson(Map<String, dynamic> json) {
    return LeopardsTrackingModel(
      status: json['status'],
      trackDate: json['track_date'],
      trackTime: json['track_time'],
      trackLocation: json['track_location'],
    );
  }
}
