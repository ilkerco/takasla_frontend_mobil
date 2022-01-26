class User {
  String? displayName;
  String? photoUrl;
  String? id;
  String? accessToken;
  int? cip;
  int? boost;
  double? longitude;
  double? latitude;
  String? countryName;
  String? subAdminArea;

  User();
  User.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    accessToken = data['accessToken'];
    photoUrl = data['photoUrl'];
    displayName = data['displayName'];
    cip = int.tryParse(data['coin'].toString());
    boost = data['boost'];
    longitude = double.parse(data['longitude'].toString());
    latitude = double.parse(data['latitude'].toString());
    countryName = data['country'];
    subAdminArea = data['subAdminArea'];
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accessToken': accessToken,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'cip': cip,
      'boost': boost,
      'longitude': longitude,
      'latitude': latitude,
      'countryName': countryName,
      'subAdminArea': subAdminArea
    };
  }

  Map<String, dynamic> toUpdateUserRequest() {
    return {
      'photoUrl': photoUrl,
      'displayName': displayName,
    };
  }
}
