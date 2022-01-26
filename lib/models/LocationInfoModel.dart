class LocationInfoModel {
  double? longitude;
  double? latitude;
  String? countryName;
  String? subAdminArea;
  bool? success;

  LocationInfoModel(
      {this.countryName,
      this.latitude,
      this.longitude,
      this.subAdminArea,
      this.success});
}
