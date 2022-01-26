import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/profile_page/edit_profile/edit_profile.dart';
import '../../root_screen/root_screen.dart';
import '../../../size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[200],

            centerTitle: false,
            pinned: true,
            floating: false,
            expandedHeight: 140, //140
            leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back_ios),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Kullanıcı ayarları",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(left: 0.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TextBar(
                  size: size,
                  border: 2,
                  text: "Profili düzenle",
                  onTap: () {
                    Navigator.of(context).push(_createRoute());
                  },
                ),
                TextBar(
                  size: size,
                  border: 1,
                  text: "Konumu değiştir",
                  onTap: () {},
                ),
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      margin: EdgeInsets.only(
                          top: getProportionateScreenWidth(0.1)),
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(width: 1, color: Colors.grey[300]!),
                            bottom:
                                BorderSide(width: 1, color: Colors.grey[300]!)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, top: 0, bottom: 0, right: 20),
                          child: SwitchListTile(
                            title: Text(
                              "Kargo",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle:
                                Text("Ürünlerimi kargoya teslim edebilirim."),
                            value: false,
                            onChanged: (bool value) {},
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextBar(
                  size: size,
                  border: 2,
                  text: "Service rules",
                  onTap: () {
                    print("asa");
                  },
                ),
                TextBar(
                  size: size,
                  border: 1,
                  text: "Licence agreement",
                  onTap: () {
                    print("user");
                  },
                ),
                TextBar(
                  size: size,
                  border: 1,
                  text: "Privacy policy",
                  onTap: () {
                    print("asa");
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                LogOut(
                  size: size,
                  border: 2,
                  text: "Çıkış yap",
                  onTap: () async {
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    await preferences.clear();
                    Navigator.of(context).pushAndRemoveUntil(
                        PageTransition(
                            child: LoginnPage(),
                            type: PageTransitionType.rightToLeft),
                        (route) => false);
                    /*Navigator.of(context).pushReplacement(PageTransition(
                        child: LoginnPage(),
                        type: PageTransitionType.rightToLeft));*/
                  },
                ),
                SizedBox(
                  height: 350,
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => EditProfile(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class TextBar extends StatelessWidget {
  final text;
  final border;
  final onTap;
  const TextBar({
    Key? key,
    @required this.size,
    this.text,
    this.onTap,
    this.border,
  }) : super(key: key);

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: getProportionateScreenWidth(0.1)),
        width: size!.width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: border == 1
              ? Border(
                  bottom: BorderSide(width: 1, color: Colors.grey[300]!),
                  //bottom: BorderSide(width: 1,color: Colors.grey[300])
                )
              : Border(
                  top: BorderSide(width: 1, color: Colors.grey[300]!),
                  bottom: BorderSide(width: 1, color: Colors.grey[300]!),
                  //bottom: BorderSide(width: 1,color: Colors.grey[300])
                ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20.0, top: 15, bottom: 15, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.withOpacity(.9),
                size: 16,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LogOut extends StatelessWidget {
  final text;
  final border;
  final onTap;
  const LogOut({
    Key? key,
    @required this.size,
    this.text,
    this.onTap,
    this.border,
  }) : super(key: key);

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: getProportionateScreenWidth(0.1)),
        width: size!.width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: border == 1
              ? Border(
                  bottom: BorderSide(width: 1, color: Colors.grey[300]!),
                  //bottom: BorderSide(width: 1,color: Colors.grey[300])
                )
              : Border(
                  top: BorderSide(width: 1, color: Colors.grey[300]!),
                  bottom: BorderSide(width: 1, color: Colors.grey[300]!),
                  //bottom: BorderSide(width: 1,color: Colors.grey[300])
                ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20.0, top: 15, bottom: 15, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
