class StopModel {
  final String? name;
  final double? latitude;
  final double? longitude;
  final int? timeSpentMinutes;
  final bool? isPhotoStop;
  final double? entryFeeUgx;

  StopModel({
    this.name,
    this.latitude,
    this.longitude,
    this.timeSpentMinutes,
    this.isPhotoStop,
    this.entryFeeUgx,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      name: json['name'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      timeSpentMinutes: json['timeSpentMinutes'],
      isPhotoStop: json['isPhotoStop'],
      entryFeeUgx: json['entryFeeUgx'] != null ? (json['entryFeeUgx'] as num).toDouble() : null,
    );
  }
}