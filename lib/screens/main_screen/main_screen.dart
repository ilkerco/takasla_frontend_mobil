import 'package:camera/camera.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/camera_screen/camera_example_home.dart';
import 'package:takasla/screens/create_product_screen/create_product_new.dart';
import 'package:takasla/screens/home_screen/home_screen.dart';
import 'package:takasla/screens/notifications_screen/notification_screen.dart';
import 'package:takasla/screens/chat_screen/chat_screen.dart';
import 'package:takasla/screens/ilanlar_screen/ilanlar_screen.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/screens/camera_screen/camera_screen.dart';
import 'package:takasla/services/api/takasla_api.dart';

import '../../size_config.dart';

class MainScreen extends StatefulWidget {
  static String routeName = "/main_screen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
////////IMAGEPİCKER///////////////////////////////
  int currentTab = 0;
  List<CameraDescription>? cameras;
  final List<Widget> screens = [
    HomeScreen(),
    NotificationScreen(),
    ChatScreen(),
    //CameraApp()
    IlanlarScreen()
  ];

  Widget currentScreen = HomeScreen();

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    getUsersAllChats(Provider.of<UserNotifier>(context, listen: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        body: PageStorage(
          child: currentScreen,
          bucket: bucket,
        ),
        floatingActionButton: Container(
          height: 45,
          width: 45,
          child: FloatingActionButton.extended(
              elevation: 0,
              backgroundColor: kPrimaryColor,
              onPressed: () async {
                /*HapticFeedback.vibrate();
                await Lala();
                print("sonra olması gereken");*/
                Navigator.of(context).push(PageTransition(
                    child: CCreateProduct(),
                    type: PageTransitionType.rightToLeft));
                /*Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return CameraPage(
                    cameras: cameras!,
                  );
                }));*/
              },
              label: Container(
                child: Icon(
                  Icons.camera_alt,
                  size: 26,
                ),
              )),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: StyleProvider(
          style: Style(),
          child: ConvexAppBar(
            items: [
              TabItem(
                  icon: Image.asset(
                    'assets/icons/ic_main_28.png',
                    height: 32,
                    width: 32,
                    color: currentTab == 0 ? Colors.black : Colors.grey,
                  ),
                  title: 'Home'),
              TabItem(
                  icon: Image.asset(
                    'assets/icons/ic_best_28.png',
                    color: currentTab == 1 ? Colors.black : Colors.grey,
                  ),
                  title: 'Top'),
              TabItem(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 1,
                    color: kPrimaryColor,
                  ),
                  title: 'Takasla'),
              TabItem(
                  icon: Image.asset(
                    'assets/icons/ic_chat_28.png',
                    color: currentTab == 3 ? Colors.black : Colors.grey,
                  ),
                  title: 'Message'),
              TabItem(
                  icon: Image.asset(
                    'assets/icons/ic_boost_24.png',
                    color: currentTab == 4 ? Colors.black : Colors.grey,
                  ),
                  title: 'Boost'),
            ],
            style: TabStyle.fixed,
            backgroundColor: Colors.white,
            activeColor: Colors.black,
            color: Colors.grey,
            curveSize: 65,
            height: 55,

            cornerRadius: 0,
            initialActiveIndex: 0, //optional, default as 0
            onTap: (int i) async {
              switch (i) {
                case 0:
                  setState(() {
                    currentScreen =
                        HomeScreen(); // if user taps on this dashboard tab will be active
                    currentTab = 0;
                  });
                  break;
                case 1:
                  setState(() {
                    currentScreen = NotificationScreen();
                    currentTab = 1;
                  });
                  break;
                case 2:
                  HapticFeedback.vibrate();
                  //popUpMenu(context); normali bu
                  //await Lala();
                  //print("sonra olması gereken");
                  /*Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return CameraPage(
                      cameras!,
                    );
                  }));*/
                  break;
                case 3:
                  setState(() {
                    currentScreen = ChatScreen();
                    currentTab = 3;
                  });
                  break;
                case 4:
                  setState(() {
                    currentScreen = IlanlarScreen();
                    currentTab = 4;
                  });
              }
            },
          ),
        ));
  }

  Future<void> Lala() async {
    WidgetsFlutterBinding.ensureInitialized();
    List<CameraDescription> camera = await availableCameras();
    setState(() {
      cameras = camera;
    });
  }
}

class Style extends StyleHook {
  @override
  double get activeIconSize => 40;

  @override
  double get activeIconMargin => 10;

  @override
  double get iconSize => 25;

  @override
  TextStyle textStyle(Color color) {
    return TextStyle(fontSize: 14, color: color);
  }
}
