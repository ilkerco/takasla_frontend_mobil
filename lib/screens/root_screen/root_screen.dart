import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:takasla/helpers/email_validator.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takasla/helpers/flippable_box.dart';
import 'package:takasla/helpers/password_validator.dart';
import 'package:takasla/models/SocialLoginRequest.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/introduction_screen/onboarding_page.dart';
import 'package:takasla/screens/main_screen/main_screen.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:takasla/services/auth_services/auth_service.dart';
import '../../constants.dart';
import '../../size_config.dart';

bool isLogged = false;
bool err = false;

enum AuthStatus {
  notLoggedIn,
  loggedIn,
  waiting,
  error,
}

class RootPage extends StatefulWidget {
  static String routeName = "/root";

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<RootPage> {
  //AuthStatus _authStatus = AuthStatus.waiting;
  AuthStatus _authStatus = AuthStatus.notLoggedIn;
  String? errMsg;

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    /* print("Dependency Değiştiiii!!!");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken = preferences.getString("accessToken");
    if (accessToken != null) {
      setState(() {
        isLogged = true;
      });
      User? currentUser = await getCurrentUser(accessToken);
      if (currentUser != null) {
        UserNotifier userNotifier =
            Provider.of<UserNotifier>(context, listen: false);
        userNotifier.currentUser = currentUser;
        setState(() {
          Navigator.of(context).pushNamedAndRemoveUntil(
              MainScreen.routeName, (Route<dynamic> route) => false);
          //_authStatus = AuthStatus.loggedIn;
        });
      } else {
        setState(() {
          errMsg = "Ups! Something went wrong";
          //_authStatus = AuthStatus.error;
          err = true;
          isLogged = false;
        });
      }
    } else {
      setState(() {
        _authStatus = AuthStatus.notLoggedIn;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget? retVal;
    switch (_authStatus) {
      case AuthStatus.notLoggedIn:
        retVal = OnBoardingPage(); //LoginnPage(); SplashScreen();
        print("not Logged In");
        break;
      case AuthStatus.loggedIn:
        //retVal = MainScreen();
        break;
      case AuthStatus.waiting:
        retVal = WaitScreen();
        print("Waiting");
        break;
      case AuthStatus.error:
        retVal = Container(
          child: Text(errMsg!),
        );
        break;
    }
    return retVal!;
  }
}

class WaitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          ),
        ),
      ),
    );
  }
}

class LoginnPage extends StatefulWidget {
  @override
  _LoginnPageState createState() => _LoginnPageState();
}

class _LoginnPageState extends State<LoginnPage> with TickerProviderStateMixin {
  bool _isFlipped = false;
  bool _isObscure = true;
  bool _changeCardBack = false;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _emailRecoverController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _emailRegisterController = new TextEditingController();
  TextEditingController _passwordRegisterController =
      new TextEditingController();
  double? offset;
  late AnimationController _animationController;
  late Animation<double> _animation;
  UserNotifier? userNotifier;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _recoverPassword = GlobalKey<FormState>();
  @override
  void initState() {
    userNotifier = Provider.of<UserNotifier>(context, listen: false);
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation =
        Tween<double>(begin: 1.0, end: 0.8).animate(_animationController);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    offset = MediaQuery.of(context).size.height;
    //await Future.delayed(Duration(milliseconds: 1500));
    if (!isLogged) {
      setState(() {
        offset = offset! * .65;
        err = false;
      });
    }
  }

  void _showAlert() {
    AlertDialog dialog = new AlertDialog(
      content: Container(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Lütfen bekleyin..."),
            SizedBox(
              width: 10,
            ),
            CircularProgressIndicator(
                backgroundColor: kPrimaryColor,
                valueColor: AlwaysStoppedAnimation<Color>(kSecondaryColor)),
          ],
        ),
      )),
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value();
              },
              child: dialog);
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Size size = MediaQuery.of(context).size;
    if (err) {
      _scaffoldKey.currentState!.showSnackBar(
          new SnackBar(content: new Text("Giriş yapılırken hata oluştu!")));
    }
    return WillPopScope(
      onWillPop: () {
        print(_isFlipped);
        if (_isFlipped) {
          setState(() {
            _isFlipped = !_isFlipped;

            //_changeCardBack = false;
          });
          return Future.value(false);
        }
        //Navigator.of(context).pop();
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: Colors.grey[200],
        body: Stack(children: [
          Container(
            width: size.width,
            height: size.height * .45,
            color: kPrimaryColor,
            child: Column(
              children: [
                Container(
                  //height: 80,
                  margin:
                      EdgeInsets.only(top: getProportionateScreenHeight(101)),
                  child: Image.asset('assets/icons/takas_intro_logo.png'),
                ),
                Container(
                  height: 15,
                ),
                Text(
                  "Etrafındaki ürünleri gör ve takasla.",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          ScaleTransition(
            scale: _animation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15),
                child: FlippableBox(
                  front: buildLoginContainer(size),
                  back: !_changeCardBack
                      ? buildRegisterContainer(size)
                      : buildRememberPasswordContainer(size),
                  isFlipped: _isFlipped,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Container buildRegisterContainer(Size size) {
    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ], borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _registerFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailRegisterController,
                  validator: (value) => value!.isValidEmail()
                      ? null
                      : "Lütfen geçerli bir e-posta girin",
                  cursorWidth: 2.5,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      floatingLabelStyle: TextStyle(color: kTextColor),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.5)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      labelText: "E-Posta"),
                ),
                Container(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordRegisterController,
                  validator: (value) {
                    if (!validateStructure(value!)) {
                      return "Şifreniz 6 - 16 karakter arasında olmalıdır.";
                    } else {
                      return null;
                    }
                  },
                  cursorColor: kPrimaryColor,
                  cursorWidth: 2.5,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                      suffixIcon: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                          child: Icon(
                            Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      floatingLabelStyle: TextStyle(color: kTextColor),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.5)),
                      border: OutlineInputBorder(),
                      labelText: "Şifre"),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.blueGrey[50]),
                  child: Padding(
                      padding: EdgeInsets.all(15),
                      child: RichText(
                        text: TextSpan(
                          text: 'Şifreniz ',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                          children: const <TextSpan>[
                            TextSpan(
                                text: 'en az 7 karakter',
                                style: TextStyle(color: Colors.black)),
                            TextSpan(text: ' ve'),
                            TextSpan(
                                text: ' en fazla 15 karakter',
                                style: TextStyle(color: Colors.black)),
                            TextSpan(text: ' olmalı,'),
                            TextSpan(
                                text: ' harf ve rakam ',
                                style: TextStyle(color: Colors.black)),
                            TextSpan(text: 'içermelidir.'),
                          ],
                        ),
                      )),
                ),
                Container(
                  height: 15,
                ),
                TextButton(
                  onPressed: () async {
                    if (_registerFormKey.currentState!.validate()) {
                      _animationController.forward();
                      //_registerFormKey.currentState!.save();
                      await registerWithEmail(
                              userNotifier!,
                              LoginRequestModel(_emailRegisterController.text,
                                  _passwordRegisterController.text))
                          .then((value) {
                        if (!value.success) {
                          _scaffoldKey.currentState!.showSnackBar(
                              new SnackBar(content: new Text(value.message)));
                        } else {
                          Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                  transitionDuration: Duration(seconds: 1),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    animation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.elasticInOut);
                                    return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                        alignment: Alignment.center);
                                  },
                                  pageBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secAnimation) {
                                    return MainScreen();
                                  }));
                        }
                      });
                      //await Future.delayed(Duration(seconds: 2));
                      _animationController.reverse();
                    }
                  },
                  child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 15,
                              offset:
                                  Offset(0, 0.75), // changes position of shadow
                            ),
                          ],
                          color: kPrimaryColor),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child: Center(
                          child: Text(
                            "ÜYE OL",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: "Üye Ol'a basarak",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      children: const <TextSpan>[
                        TextSpan(
                            text: " Üyelik Koşulları'",
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline)),
                        TextSpan(text: 'nı kabul ediyorum.'),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 25,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isFlipped = !_isFlipped;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Üye misin? ",
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54),
                            children: const <TextSpan>[
                              TextSpan(
                                  text: "Giriş Yap",
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Container buildLoginContainer(Size size) {
    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ], borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _loginFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  validator: (value) => value!.isValidEmail()
                      ? null
                      : "Lütfen geçerli bir e-posta girin",
                  cursorWidth: 2.5,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      floatingLabelStyle: TextStyle(color: kTextColor),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.5)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      labelText: "E-Posta"),
                ),
                Container(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  cursorColor: kPrimaryColor,
                  cursorWidth: 2.5,
                  obscureText: _isObscure,
                  validator: (value) {
                    if (value!.length <= 6 || value.length >= 15) {
                      return "Şifreniz 6 - 16 karakter arasında olmalıdır.";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      suffixIcon: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                          child: Icon(
                            Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      floatingLabelStyle: TextStyle(color: kTextColor),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.5)),
                      border: OutlineInputBorder(),
                      labelText: "Şifre"),
                ),
                Container(
                  height: 12,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _changeCardBack = true;
                        _isFlipped = !_isFlipped;
                      });
                    },
                    child: Text(
                      "Şifremi unuttum",
                      style: TextStyle(color: kPrimaryColor, fontSize: 13),
                    ),
                  ),
                ),
                Container(
                  height: 15,
                ),
                TextButton(
                  onPressed: () async {
                    if (_loginFormKey.currentState!.validate()) {
                      _animationController.forward();
                      _loginFormKey.currentState!.save();
                      await loginWithEmail(
                              userNotifier!,
                              new LoginRequestModel(_emailController.text,
                                  _passwordController.text))
                          .then((value) {
                        if (!value.success) {
                          _scaffoldKey.currentState!.showSnackBar(
                              new SnackBar(content: new Text(value.message)));
                        } else {
                          Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                  transitionDuration: Duration(seconds: 1),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    animation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.elasticInOut);
                                    return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                        alignment: Alignment.center);
                                  },
                                  pageBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secAnimation) {
                                    return MainScreen();
                                  }));
                        }
                      });
                      //await Future.delayed(Duration(seconds: 2));
                      _animationController.reverse();
                    }
                  },
                  child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 15,
                              offset:
                                  Offset(0, 0.75), // changes position of shadow
                            ),
                          ],
                          color: kPrimaryColor),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child: Center(
                          child: Text(
                            "GİRİŞ YAP",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                ),
                //Spacer(),
                Container(
                  height: 25,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _changeCardBack = false;
                            _isFlipped = !_isFlipped;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Üye değil misin? ",
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54),
                            children: const <TextSpan>[
                              TextSpan(
                                  text: "Üye Ol",
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Container buildRememberPasswordContainer(Size size) {
    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ], borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _recoverPassword,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Şifrenizi yenilemek için e-posta adresinize bir link gelecektir. Gelen linke tıklayıp yeni şifrenizi belirleyebilirsiniz.",
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 15,
                ),
                TextFormField(
                  controller: _emailRecoverController,
                  validator: (value) => value!.isValidEmail()
                      ? null
                      : "Lütfen geçerli bir e-posta girin",
                  cursorWidth: 2.5,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      floatingLabelStyle: TextStyle(color: kTextColor),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.5)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      labelText: "E-Posta"),
                ),
                Container(
                  height: 20,
                ),
                TextButton(
                  onPressed: () async {
                    if (_recoverPassword.currentState!.validate()) {
                      _animationController.forward();
                      await ForgetPassword(_emailRecoverController.text)
                          .then((value) {
                        _scaffoldKey.currentState!.showSnackBar(
                            new SnackBar(content: new Text(value.message)));
                      });
                      //_recoverPassword.currentState!.save();
                      //await Future.delayed(Duration(seconds: 2));
                      _animationController.reverse();
                    }
                  },
                  child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 15,
                              offset:
                                  Offset(0, 0.75), // changes position of shadow
                            ),
                          ],
                          color: kPrimaryColor),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 15),
                        child: Center(
                          child: Text(
                            "ŞİFREMİ YENİLE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}
