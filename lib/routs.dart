import 'package:flutter/material.dart';
import 'package:takasla/screens/main_screen/main_screen.dart';
import 'package:takasla/screens/root_screen/root_screen.dart';

final Map<String, WidgetBuilder> routes = {
  RootPage.routeName: (context) => RootPage(),
  MainScreen.routeName: (context) => MainScreen(),
};
