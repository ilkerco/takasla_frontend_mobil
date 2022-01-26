import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/screens/root_screen/root_screen.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', 0);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginnPage()),
    );
  }

  Widget _buildFullscrenImage() {
    return Image.asset(
      'assets/fullscreen.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 200]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  Widget _buildIcon(String assetName, [double width = 200]) {
    return Image.asset('assets/icons/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.black);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.black),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return SafeArea(
      child: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        globalHeader: Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: _buildIcon('takas_intro_logo.png', 100),
            ),
          ),
        ),

        pages: [
          PageViewModel(
            title: "Yükle",
            body:
                "Takaslamak istediğin ürünleri yükle ve nelerle takas edebileceğini gör.",
            image: _buildImage('splash_1.png'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Takasla",
            body: "Uygulama üstünden dilediğin ürünü seç ve takasla.",
            image: _buildImage('splash_3.png'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Kazan",
            body:
                "Uygulama üzerinden takas işlemi gerçekleştirdikçe çip kazanırsın.",
            image: _buildImage('splash_2.png'),
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        //rtl: true, // Display as right-to-left
        skip: const Text(
          'Atla',
          style: TextStyle(color: kPrimaryColor),
        ),
        next: const Icon(
          Icons.arrow_forward,
          color: kPrimaryColor,
        ),
        done: const Text('Son',
            style:
                TextStyle(fontWeight: FontWeight.w600, color: kPrimaryColor)),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: kIsWeb
            ? const EdgeInsets.all(12.0)
            : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeColor: Color(0xFFFF7643),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
