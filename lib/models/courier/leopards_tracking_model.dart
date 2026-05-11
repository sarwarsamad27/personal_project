class LeopardsTrackingModel {
  final String? status;
  final String? trackDate;
  final String? trackLocation;
  final String? reason; // Leopards "Reason" field — explains delay or failure

  LeopardsTrackingModel({
    this.status,
    this.trackDate,
    this.trackLocation,
    this.reason,
  });

  factory LeopardsTrackingModel.fromJson(Map<String, dynamic> json) {
    return LeopardsTrackingModel(
      status:        json['status'],
      trackDate:     json['track_date'],
      trackLocation: json['track_location'],
      reason:        json['reason'],
    );
  }
}
