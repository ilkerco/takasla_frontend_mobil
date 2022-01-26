import 'package:flutter/material.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:provider/provider.dart';
import 'package:takasla/screens/profile_page/profile_page.dart';
import 'package:takasla/services/api/takasla_api.dart';

import '../../constants.dart';
import 'home_screen_body.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home_screen";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  User? currentUser;

  @override
  void initState() {
    //WidgetsBinding.instance!.addObserver(this);
    /*UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);
    currentUser = new User.fromMap(userNotifier.CurrentUser!.toMap());*/
    //print(currentUser!.toMap());
    super.initState();
  }

  @override
  void dispose() {
    //WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  /* @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("devam edildi home screen**********************************");
    }
    if (state == AppLifecycleState.detached) {
      print("detacheteedd olduuuuuuuuuuuuuuuu****************");
    }
    if (state == AppLifecycleState.inactive) {
      print("inactiveeeee olduuuuuuuuuuu home screeen*********");
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Top Ürünler",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        leading: InkWell(
          splashColor: kPrimaryColor,
          borderRadius: BorderRadius.circular(60),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return ProfilePage();
            }));
          },
          child: Padding(
            padding: EdgeInsets.all(14),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  Provider.of<UserNotifier>(context, listen: false)
                      .CurrentUser!
                      .photoUrl!),
            ),
          ),
        ),
        actions: [
          Icon(
            Icons.search,
            size: 28,
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            await getProducts(
                Provider.of<ProductNotifier>(context, listen: false),
                Provider.of<UserNotifier>(context, listen: false));
          },
          child: Consumer<ProductNotifier>(
              builder: (context, productNotifier, _) => Body())),
    );
  }
}
