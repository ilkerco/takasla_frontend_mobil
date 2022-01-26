import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xfff7d03a); //0xfff7d03a
const kPrimaryLightColor = Color(0xFFFFECDF);
const kBackGroundColor = Color(0xF2FFFFFF);
var kPrimaryGradientColor = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA53E), Color(0xFFFF7643)]);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Lütfen mail adresini gir";
const String kInvalidEmailError = "Lütfen geçerli bir mail adresi gir";
const String kPassNullError = "Lütfen şifrenizi giriniz";
const String kShortPassError = "Şifre en az 8 karakterden oluşmalı";
const String kMatchPassError = "Şifreler eşleşmiyor";
//const String localConnectionString = "http://10.0.2.2:49544"; old api
//const String localConnectionString = "http://10.0.2.2:5000";
const String localConnectionString = "https://ilkersargin.site";
