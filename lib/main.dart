import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/routs.dart';
import 'package:takasla/screens/introduction_screen/onboarding_page.dart';
import 'package:takasla/screens/main_screen/main_screen.dart';
import 'package:takasla/screens/root_screen/root_screen.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:takasla/size_config.dart';
import 'package:takasla/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'notifiers/image_notifier.dart';
import 'notifiers/product_notifier.dart';
import 'notifiers/user_notifier.dart';

int? isviewed;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  /*SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: appBarTheme(),
              /* textTheme: GoogleFonts.latoTextTheme(
                  Theme.of(context).textTheme),*/ //textTheme(),
              //inputDecorationTheme: inputDecorationTheme(),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              bottomSheetTheme:
                  BottomSheetThemeData(backgroundColor: Colors.transparent)),
          home: Deneme() //isviewed == 0 ? LoginnPage() : OnBoardingPage()
          //initialRoute: RootPage.routeName,
          //routes: routes,
          ),
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => ImageNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserNotifier(),
        )
      ],
    );
  }
}

class Deneme extends StatefulWidget {
  const Deneme({Key? key}) : super(key: key);

  @override
  _DenemeState createState() => _DenemeState();
}

class _DenemeState extends State<Deneme> {
  @override
  void initState() {
    // TODO: implement initState
    _doSomeStuff();
    super.initState();
  }

  Future<void> _doSomeStuff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    if (accessToken != null) {
      await getCurrentUser(accessToken).then((value) {
        Provider.of<UserNotifier>(context, listen: false).currentUser = value!;
      });
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: Duration(seconds: 1),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            animation =
                CurvedAnimation(parent: animation, curve: Curves.elasticInOut);
            return ScaleTransition(
                scale: animation, child: child, alignment: Alignment.center);
          },
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secAnimation) {
            return MainScreen();
          }));
      /*Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MainScreen()));*/
    } else {
      Navigator.of(context).pushReplacement(PageTransition(
          child: LoginnPage(), type: PageTransitionType.rightToLeft));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          Center(
            child: Image.asset('assets/icons/takas_intro_logo.png'),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 150),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
