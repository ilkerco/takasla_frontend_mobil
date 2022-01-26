import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/product_detail/product_detail.dart';
import 'package:takasla/screens/profile_page/profile_settings/profile_settings.dart';
import 'package:takasla/services/api/takasla_api.dart';

import '../../size_config.dart';

class ProfilePage extends StatefulWidget {
  //final User? user;
  //final bool? isCurrentUser;
  const ProfilePage({
    Key? key,
    /*this.user, this.isCurrentUser*/
  }) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //UserNotifier? userNotifier;
  //ProductNotifier? productNotifier;
  @override
  void initState() {
    //userNotifier = Provider.of<UserNotifier>(context, listen: false);
    //productNotifier = Provider.of<ProductNotifier>(context, listen: false);
    getProductsByUser(
        Provider.of<UserNotifier>(context, listen: false).CurrentUser!,
        Provider.of<ProductNotifier>(context, listen: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, userNotifier, _) => Scaffold(
        backgroundColor: Colors.grey[100],
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
                //title:Text("asd"),
                centerTitle: false,
                pinned: true,
                floating: false,
                expandedHeight: 190,
                backgroundColor: Colors.grey[100],
                leading: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_ios)),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                        onTap: () {
                          print("tıklandı");
                        },
                        child: Icon(Icons.share)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return ProfileSettings();
                          }));
                        },
                        child: Icon(Icons.settings)),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      userNotifier.CurrentUser!.displayName!,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    collapseMode: CollapseMode.pin,
                    centerTitle: true,
                    background: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 45),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                  userNotifier.CurrentUser!.photoUrl!),
                            ),
                          ),
                        )
                      ],
                    ))),
            SliverPadding(
              padding: EdgeInsets.only(left: 16, right: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Center(
                    child: Text(
                      userNotifier.CurrentUser!.subAdminArea! +
                          " / " +
                          //"Düzce / Merkez",
                          userNotifier.CurrentUser!.countryName!,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200]),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Icon(Icons.flight),
                                    ),
                                  ),
                                  Text(
                                    "Boost: " +
                                        userNotifier.CurrentUser!.boost
                                            .toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 18,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200]),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Icon(Icons.flight),
                                    ),
                                  ),
                                  Text(
                                      "Çip:" +
                                          userNotifier.CurrentUser!.cip
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 18,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ]),
              ),
            ),
            Consumer<ProductNotifier>(
              builder: (context, productNotifier, _) => SliverList(
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildBuilderDelegate(
                  // The builder function returns a ListTile with a title that
                  // displays the index of the current item.
                  (context, index) => Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            productNotifier.currentProduct =
                                productNotifier.userProductList[index];
                            print("asdadss");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ProductDetail(
                                product: productNotifier.userProductList[index],
                                productOwner: userNotifier.CurrentUser,
                                isUserOwner: true,
                              );
                            }));
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width * .6,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    image: NetworkImage(productNotifier
                                        .userProductList[index].images![0]
                                        .toString()),
                                    fit: BoxFit.cover)),
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(
                                        "assets/icons/cargo-truck.svg",
                                        width: getProportionateScreenWidth(25),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(productNotifier.userProductList[index].title!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/coin.svg",
                              width: getProportionateScreenWidth(18),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "254",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Builds 1000 ListTiles
                  childCount: productNotifier.userProductList.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
