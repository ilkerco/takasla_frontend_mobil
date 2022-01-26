import 'package:dio/dio.dart';
//import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takasla/models/LocationInfoModel.dart';
import 'package:takasla/models/SocialLoginRequest.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/user_notifier.dart';

import '../../constants.dart';

//final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: "864347380784-3jt27pm89godgfstkljgk71udrd27inq.apps.googleusercontent.com");
Future<LoginResponseModel> ForgetPassword(String email) async {
  try {
    var dio = Dio();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Response loginResponse = await dio.post(
        localConnectionString + "/api/auth/forgetpassword?email=" + email);

    return LoginResponseModel(true, loginResponse.data["message"]);
  } on DioError catch (ex) {
    return LoginResponseModel(false, ex.response!.data["message"]);
  }
}

Future<LoginResponseModel> loginWithEmail(
    UserNotifier userNotifier, LoginRequestModel loginModel) async {
  try {
    print(localConnectionString);
    var dio = Dio();
    print(loginModel.toMap());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Response loginResponse = await dio.post(
        localConnectionString + "/api/auth/login",
        data: loginModel.toMap());
    Response getCurrentUserResponse =
        await dio.get(localConnectionString + "/api/home/getCurrentUser",
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization': 'Bearer ' + loginResponse.data
            }));
    userNotifier.currentUser = new User.fromMap(getCurrentUserResponse.data);
    userNotifier.CurrentUser!.accessToken = loginResponse.data;
    preferences.setString("accessToken", loginResponse.data);

    return LoginResponseModel(true, loginResponse.data);
  } on DioError catch (ex) {
    return LoginResponseModel(false, ex.response!.data);
  }
}

Future<LoginResponseModel> registerWithEmail(
    UserNotifier userNotifier, LoginRequestModel loginModel) async {
  try {
    print("Register metodu çalıştı");
    var dio = Dio();
    print(loginModel.toMap());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Response loginResponse = await dio.post(
        localConnectionString + "/api/auth/register",
        data: loginModel.toMap());
    Response getCurrentUserResponse =
        await dio.get(localConnectionString + "/api/home/getCurrentUser",
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization': 'Bearer ' + loginResponse.data
            }));
    userNotifier.currentUser = new User.fromMap(getCurrentUserResponse.data);
    userNotifier.CurrentUser!.accessToken = loginResponse.data;
    preferences.setString("accessToken", loginResponse.data);

    return LoginResponseModel(true, loginResponse.data);
  } on DioError catch (ex) {
    print(ex);
    return LoginResponseModel(false, ex.response!.data);
  }
}

/*Future<bool> googleSignIn(UserNotifier userNotifier) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);
  var _googleSignInAccount = await _googleSignIn.signIn();

  if (_googleSignInAccount != null) {
    GoogleSignInAuthentication _googleAuth =
        await _googleSignIn.currentUser!.authentication;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String googleAccesToken = _googleAuth.accessToken!;
    LocationInfoModel locationInfoModel = await getLocationInfo();
    if (!locationInfoModel.success!) {
      return false;
    }

    var dio = Dio();
    SocialLoginRequestModel socialLoginRequest = new SocialLoginRequestModel(
        googleAccesToken,
        locationInfoModel.longitude!,
        locationInfoModel.latitude!,
        "null",
        "null");

    try {
      Response googleAuthResponse = await dio.post(
          localConnectionString + "/api/auth/google",
          data: socialLoginRequest.toMap());
      print(googleAuthResponse.statusCode);
      String _jwtToken = googleAuthResponse.data.toString();
      //String _jwtToken = googleAuthResponse.data['token'].toString();
      Response getCurrentUserResponse = await dio.get(
          localConnectionString + "/api/home/getCurrentUser",
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + _jwtToken
          }));
      print(getCurrentUserResponse.statusCode);
      print("Jwt Token : " + _jwtToken);
      User user = new User();
      user = User.fromMap(getCurrentUserResponse.data);
      user.accessToken = _jwtToken;
      userNotifier.currentUser = user;
      preferences.setString("accessToken", user.accessToken!);
      return true;
    } catch (e) {
      return false;
    }
  } else {
    return false;
  }
}

/*Future<bool> facebookSignIn(UserNotifier userNotifier) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var facebookLogin = new FacebookLogin();
  var result = await facebookLogin.logIn(['email']);
  String facebookAccesToken = result.accessToken.token;
  LocationInfoModel locationInfoModel = await getLocationInfo();
  if (!locationInfoModel.success) {
    return false;
  }

  var dio = Dio();
  SocialLoginRequestModel socialLoginRequest = new SocialLoginRequestModel(
      facebookAccesToken,
      locationInfoModel.longitude,
      locationInfoModel.latitude,
      locationInfoModel.subAdminArea,
      locationInfoModel.countryName);
  try {
    Response facebookAuthResponse = await dio.post(
        localConnectionString + "/api/v1/identity/auth/fb",
        data: socialLoginRequest.toMap());
    String _jwtToken = facebookAuthResponse.data['token'].toString();
    Response getCurrentUserResponse = await dio.get(
        localConnectionString + "/api/v1/users/getCurrentUser",
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + _jwtToken
        }));
    print(getCurrentUserResponse.statusCode);
    User user = new User();
    user = User.fromMap(getCurrentUserResponse.data);
    user.accessToken = _jwtToken;
    userNotifier.currentUser = user;
    return true;
  } catch (e) {
    return false;
  }
}*/

Future<LocationInfoModel> getLocationInfo() async {
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.always) {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    /*final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);*/
    return new LocationInfoModel(
        /*subAdminArea: addresses.first.subAdminArea,
        countryName: addresses.first.countryName,*/
        latitude: position.latitude,
        longitude: position.longitude,
        success: true);
  }
  return new LocationInfoModel(success: false);
}
*/