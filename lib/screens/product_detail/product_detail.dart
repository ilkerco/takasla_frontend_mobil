import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/edit_product_screen/edit_product.dart';

import '../../constants.dart';

class ProductDetail extends StatefulWidget {
  static String routeName = "/product_detailss";
  final bool? isUserOwner;
  final User? productOwner;
  final Product? product;

  const ProductDetail(
      {Key? key, this.isUserOwner, this.productOwner, this.product})
      : super(key: key);
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  UserNotifier? userNotifier;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  User? currentUser;
  ProductNotifier? productNotifier;
  String? category;
  double? distance;
  int? _current;
  String? distanceText;
  @override
  void initState() {
    _current = 0;
    initializeDateFormatting('tr');
    print(widget.isUserOwner.toString() + " is user owner");
    userNotifier = Provider.of<UserNotifier>(context, listen: false);
    currentUser = userNotifier!.CurrentUser;
    productNotifier = Provider.of<ProductNotifier>(context, listen: false);
    category = widget.product!.category;
    print(widget.productOwner!.photoUrl! + "photourllllllll");
    distance = Geolocator.distanceBetween(
        userNotifier!.CurrentUser!.latitude!,
        userNotifier!.CurrentUser!.longitude!,
        widget.productOwner!.latitude!,
        widget.productOwner!.longitude!);
    if (distance! >= 1000) {
      double kms = distance! / 1000;
      distanceText = kms.toStringAsFixed(3) + " km";
    } else if (distance! > 100) {
      distanceText = distance!.toStringAsFixed(3) + " m";
    } else {
      distanceText = "10 m";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: !widget.isUserOwner!
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: kPrimaryColor,
                        elevation: 15,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(.3),
                          highlightColor: Colors.white.withOpacity(.3),
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            print("asdasd00");
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.white),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Icon(
                                          Icons.repeat,
                                          color: kPrimaryColor,
                                        ),
                                      )),
                                  Text(
                                    " Teklif gönder",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        elevation: 15,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            print("aslas");
                          },
                          splashColor: kPrimaryColor.withOpacity(.5),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      " Mesaj at",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: kPrimaryColor,
                        elevation: 15,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(.3),
                          highlightColor: Colors.white.withOpacity(.3),
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            print("asdasd00");
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.white),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Icon(
                                          Icons.flight,
                                          color: kPrimaryColor,
                                        ),
                                      )),
                                  Text(
                                    " Boostla",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          body: SingleChildScrollView(
            child: Container(
              width: size.width,
              child: Stack(
                children: [
                  widget.product!.images!.length > 1
                      ? CarouselSlider.builder(
                          options: CarouselOptions(
                              height: size.height * 0.75,
                              scrollDirection: Axis.horizontal,
                              initialPage: widget.product!.images!.length,
                              viewportFraction: 1,
                              onPageChanged: (int index, _) {
                                setState(() {
                                  _current = index;
                                });
                              }),
                          itemCount: widget.product!.images!.length,
                          itemBuilder: (BuildContext context, int itemIndex,
                                  _) =>
                              Container(
                                height: size.height * 0.75,
                                width: size.width,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            widget.product!.images![itemIndex]),
                                        fit: BoxFit.cover)),
                              ))
                      : Container(
                          height: size.height * 0.75,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      NetworkImage(widget.product!.images![0]),
                                  fit: BoxFit.cover)),
                        ),
                  widget.product!.images!.length > 1
                      ? SafeArea(
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            alignment: Alignment.center,
                            width: size.width,
                            height: 25,
                            child: Center(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: widget.product!.images!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Align(
                                      child: Container(
                                        width: 150 /
                                            widget.product!.images!.length,
                                        height: 4,
                                        margin: EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                            color: _current == index
                                                ? Colors.white
                                                : Colors.black.withOpacity(.5),
                                            borderRadius:
                                                BorderRadius.circular(60)),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        )
                      : Container(),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black38),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            widget.isUserOwner!
                                ? InkWell(
                                    onTap: () {
                                      showPopUp(context);
                                    },
                                    child: Icon(
                                      Icons.filter_list,
                                      color: Colors.white,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: size.width,
                    margin: EdgeInsets.only(top: size.height * 0.7),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/coin.svg",
                              height: 32,
                              width: 32,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.product!.cip.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 25),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.product!.title!,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Kategori: $category",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(widget.product!.description!),
                        SizedBox(
                          height: 9,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            Text(distanceText!)
                          ],
                        ),
                        SizedBox(
                          height: 9,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    Text(widget.product!.createdAt.toString()),
                                    /*Text(DateFormat('d MMMM yy', 'TR').format(
                                        DateFormat('dd.MM.yyyy', 'TR')
                                            .parse(widget.product.createdAt))),*/
                                    //Text(DateFormat('dd.MM.yyyy HH:mm:ss','TR').parse(productNotifier.currentProduct.createdAt).toString())
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[300]!),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    Text(" 12")
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey[300]!),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/cargo-truck.svg",
                                      width: 32,
                                    ),
                                    Text(
                                      " Kargo kullanılabilir.",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Material(
                          child: InkWell(
                            onTap: () {
                              print("tıkladı");
                            },
                            splashColor: kPrimaryColor.withOpacity(.6),
                            highlightColor: kPrimaryColor.withOpacity(.3),
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                        widget.productOwner!.photoUrl!),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    widget.productOwner!.displayName!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Material(
                          child: InkWell(
                              splashColor: kPrimaryColor.withOpacity(.6),
                              highlightColor: kPrimaryColor.withOpacity(0.3),
                              onTap: () {
                                print("paylas");
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[300]!),
                                        top: BorderSide(
                                            color: Colors.grey[300]!))),
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Center(
                                      child: Text(
                                    "Bu ilanı paylaş",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )),
                                ),
                              )),
                        ),
                        Material(
                          child: InkWell(
                              splashColor: Colors.redAccent.withOpacity(0.6),
                              highlightColor: Colors.redAccent.withOpacity(0.3),
                              onTap: () {
                                print("paylas");
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[300]!))),
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Center(
                                      child: Text(
                                    "Sorun bildir",
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void showPopUp(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (builder) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              //height: MediaQuery.of(context).size.height * .45,
              padding: EdgeInsets.only(top: 20, left: 40, bottom: 15),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return EditProduct();
                  }));
                },
                child: Row(
                  children: [
                    Text(
                      "Düzenle",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ));
        });
  }
}
