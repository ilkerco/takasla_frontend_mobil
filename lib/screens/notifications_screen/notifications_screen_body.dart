import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:flutter_swiper/flutter_swiper.dart';
//import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:takasla/models/CreateChatModel.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/size_config.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/screens/product_detail/product_detail.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:takasla/screens/messages_screen/messages_screen.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:card_swiper/card_swiper.dart';

class SwipeProductsBody extends StatefulWidget {
  @override
  _SwipeProductsBodyState createState() => _SwipeProductsBodyState();
}

class _SwipeProductsBodyState extends State<SwipeProductsBody> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper(
        itemCount: Provider.of<ProductNotifier>(context, listen: false)
            .productList
            .length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.only(bottom: 30, top: 30),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      print("going to do product detail page");
                      User productOwner;
                      Provider.of<ProductNotifier>(context, listen: false)
                              .currentProduct =
                          Provider.of<ProductNotifier>(context, listen: false)
                              .productList[index];
                      bool isUserOwner =
                          Provider.of<ProductNotifier>(context, listen: false)
                                  .productList[index]
                                  .ownerId ==
                              Provider.of<UserNotifier>(context, listen: false)
                                  .CurrentUser!
                                  .id;
                      if (isUserOwner) {
                        productOwner = new User.fromMap(
                            Provider.of<UserNotifier>(context, listen: false)
                                .CurrentUser!
                                .toMap());
                      } else {
                        productOwner = await getUserById(
                            Provider.of<ProductNotifier>(context, listen: false)
                                .productList[index],
                            Provider.of<UserNotifier>(context, listen: false));
                      }
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ProductDetail(
                            isUserOwner: isUserOwner,
                            productOwner: productOwner,
                            product: Provider.of<ProductNotifier>(context,
                                    listen: false)
                                .productList[index]);
                      }));
                    },
                    child: CachedNetworkImage(
                      imageUrl:
                          Provider.of<ProductNotifier>(context, listen: false)
                              .productList[index]
                              .images![0],
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Shimmer.fromColors(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          baseColor: Colors.white,
                          highlightColor: Colors.grey[300]!),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        height: 49,
                        margin:
                            EdgeInsets.only(left: 15, bottom: 15, right: 15),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Provider.of<ProductNotifier>(context,
                                              listen: false)
                                          .productList[index]
                                          .title!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/coin.svg",
                                          width:
                                              getProportionateScreenWidth(15),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                          child: Text(
                                            Provider.of<ProductNotifier>(
                                                        context,
                                                        listen: false)
                                                    .productList[index]
                                                    .cip
                                                    .toString() +
                                                " coins - 74 km",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        /*Text(
                                          " - 7433 km",
                                          style: TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        )*/
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Material(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor,
                                child: InkWell(
                                  onTap: () async {
                                    print("tiklandim");

                                    var ownerId = Provider.of<ProductNotifier>(
                                            context,
                                            listen: false)
                                        .productList[index]
                                        .ownerId;

                                    var productId =
                                        Provider.of<ProductNotifier>(context,
                                                listen: false)
                                            .productList[index]
                                            .id;
                                    User owner = await getUserByIdd(
                                        ownerId!,
                                        Provider.of<UserNotifier>(context,
                                            listen: false));
                                    if (ownerId ==
                                        Provider.of<UserNotifier>(context,
                                                listen: false)
                                            .CurrentUser!
                                            .id) {
                                      print("Bu urun zatem s,z,m");
                                    } else {
                                      await createFirstChat(
                                          CreateChatModel(
                                              connectionId: null,
                                              suggestedProductId: null,
                                              targetProductId:
                                                  Provider.of<ProductNotifier>(
                                                          context,
                                                          listen: false)
                                                      .productList[index]
                                                      .id,
                                              toId: owner.id),
                                          Provider.of<UserNotifier>(context,
                                              listen: false));
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return MessagesScreen(
                                          productOwner: owner,
                                          targetProduct:
                                              Provider.of<ProductNotifier>(
                                                      context,
                                                      listen: false)
                                                  .productList[index],
                                          suggestedProduct: null,
                                        );
                                      }));
                                    }
                                  },
                                  splashColor: Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                        //color: kPrimaryColor,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit
                                                .tight, //FontAwesome.comment,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Image.asset(
                                                    'assets/icons/ic_message_24.png',
                                                    height: 24,
                                                  ) /*Icon(
                                                  Icons.comment,
                                                  color: kPrimaryColor,
                                                  size: 16,
                                                ),*/
                                                  ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Container(
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Provider.of<ProductNotifier>(
                                                                  context,
                                                                  listen: false)
                                                              .productList[
                                                                  index]
                                                              .ownerId !=
                                                          Provider.of<UserNotifier>(
                                                                  context,
                                                                  listen: false)
                                                              .CurrentUser!
                                                              .id
                                                      ? Text(
                                                          "Send",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 17),
                                                        )
                                                      : Text(
                                                          "Düzenle",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 17),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  )
                ],
              ));
        },
        viewportFraction: 0.87,
        scale: 0.87,
        loop: false,
      ),
    );
  }
}
