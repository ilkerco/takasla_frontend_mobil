import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/product_detail/product_detail.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:geolocator/geolocator.dart';

import '../../size_config.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      "Elektronik",
      "Spor ve Outdoor",
      "Araba",
      "Ev Eşyaları",
      "Oyun",
      "Araç Parçaları",
      "Bahçe ve Hırdavat",
      "Moda ve Aksesuar",
      "Film, Kitap ve Müzik",
      "Diğer"
    ];
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              padding: EdgeInsets.only(left: 7, right: 0, top: 10),
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: Container(
                      height: 0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey.withOpacity(.25), width: 1.2),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 14, right: 14, top: 6, bottom: 6),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7.0, right: 7),
              child: Container(
                height: 110,
                width: double.infinity,
                padding: EdgeInsets.only(left: 7, right: 7),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.greenAccent.withOpacity(.35)),
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                            'assets/images/ic_pic_light_star_184.png')),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset('assets/images/pic_coins_pocket.png'),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 12, left: 12),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Çipler neden önemli?",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            "Daha fazla gör",
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            //Categories(),
            SizedBox(
              height: getProportionateScreenWidth(20),
            ),
            //Expanded(child: Prodcts()),
            //Prodcts(),
            ProductWaiter()
          ],
        ),
      ),
    );
  }
}

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  UserNotifier? userNotifier;
  ProductNotifier? productNotifier;

  @override
  void initState() {
    productNotifier = Provider.of<ProductNotifier>(context, listen: false);
    userNotifier = Provider.of<UserNotifier>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: productNotifier!.productList.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () async {
                User productOwner;
                productNotifier!.currentProduct =
                    productNotifier!.productList[index];
                bool isUserOwner =
                    productNotifier!.productList[index].ownerId ==
                        userNotifier!.CurrentUser!.id;
                if (isUserOwner) {
                  productOwner =
                      new User.fromMap(userNotifier!.CurrentUser!.toMap());
                } else {
                  productOwner = await getUserById(
                      productNotifier!.productList[index], userNotifier!);
                }
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return ProductDetail(
                      isUserOwner: isUserOwner,
                      productOwner: productOwner,
                      product: productNotifier!.productList[index]);
                }));
              },
              child: ProductCard(product: productNotifier!.productList[index]));
        });
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    this.product,
  }) : super(key: key);
  final Product? product;
  @override
  Widget build(BuildContext context) {
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);
    double distance =
        150; /*Geolocator.distanceBetween(
        userNotifier.CurrentUser!.latitude!,
        userNotifier.CurrentUser!.longitude!,
        product!.latitude!,
        product!.longitude!);*/
    String distanceText = " ";
    if (distance >= 1000) {
      double kms = distance / 1000;
      distanceText += kms.toStringAsFixed(3) + " km";
    } else if (distance > 100) {
      distanceText += distance.toStringAsFixed(3) + " m";
    } else {
      distanceText += "10 m";
    }

    return Column(
      children: [
        Container(
          width: getProportionateScreenWidth(170),
          height: getProportionateScreenWidth(170),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 7,
                  offset: Offset(0, 3))
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: product!.images![0],
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(left: 7, bottom: 7, right: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/cargo-truck.svg",
                        width: getProportionateScreenWidth(20),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Text(
                            "$distanceText",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: getProportionateScreenWidth(5),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              product!.title!.length > 20
                  ? Text(
                      product!.title!.substring(0, 21) + "...",
                      style: TextStyle(color: Colors.black),
                      maxLines: 1,
                    )
                  : Text(
                      product!.title!,
                      style: TextStyle(color: Colors.black),
                    ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/icons/coin.svg",
                width: getProportionateScreenWidth(18),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                product!.cip.toString(),
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(
                width: 5,
              ),
              Text("çip")
            ],
          ),
        )
      ],
    );
  }
}

class ProductWaiter extends StatefulWidget {
  @override
  _ProductWaiterState createState() => _ProductWaiterState();
}

class _ProductWaiterState extends State<ProductWaiter> {
  bool isLoading = true;
  UserNotifier? userNotifier;
  ProductNotifier? productNotifier;
  @override
  void initState() {
    productNotifier = Provider.of<ProductNotifier>(context, listen: false);
    userNotifier = Provider.of<UserNotifier>(context, listen: false);
    if (productNotifier!.productList.isEmpty) {
      //print("Cagrildim");
      getAllProductsAsync(userNotifier!, productNotifier!).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? Products() : ShimmerProducts();
  }
}

Future<void> getAllProductsAsync(
    UserNotifier userNotifier, ProductNotifier productNotifier) async {
  await getProducts(productNotifier, userNotifier);
  /*for (Product pro in productNotifier.productList) {
    print(pro.toMapwithId());
    print("asdasdadssd");
  }*/
}

class ShimmerProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int offset = 0;
    int time = 800;
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: 12,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          offset += 5;
          time = 800 + offset;
          return Shimmer.fromColors(
            highlightColor: Colors.white,
            baseColor: Colors.grey[300]!,
            period: Duration(milliseconds: time),
            child: Column(
              children: [
                Container(
                  width: getProportionateScreenWidth(170),
                  height: getProportionateScreenWidth(170),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 7,
                            offset: Offset(0, 3))
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey),
                ),
                SizedBox(
                  height: getProportionateScreenWidth(5),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Container(
                    height: 15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenWidth(5),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey),
                    height: 15,
                    width: double.infinity,
                  ),
                )
              ],
            ),
          );
        });
  }
}
