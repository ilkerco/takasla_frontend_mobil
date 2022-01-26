class SocialLoginRequestModel {
  String accessToken;
  double longitude;
  double latitude;
  String subAdminArea;
  String country;

  SocialLoginRequestModel(this.accessToken, this.longitude, this.latitude,
      this.subAdminArea, this.country);

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'longitude': longitude,
      'latitude': latitude,
      'subAdminArea': subAdminArea,
      'country': country,
    };
  }
}

class LoginRequestModel {
  String email;
  String password;

  LoginRequestModel(this.email, this.password);

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponseModel {
  bool success;
  String message;

  LoginResponseModel(this.success, this.message);

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
    };
  }
}
