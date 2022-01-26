import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/product_detail/product_detail.dart';
import 'package:takasla/services/api/takasla_api.dart';

import '../../constants.dart';
import '../../size_config.dart';

class CreateProduct extends StatefulWidget {
  final List<String>? images;

  const CreateProduct({Key? key, this.images}) : super(key: key);
  @override
  _CreateProductState createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final myControllerName = TextEditingController();
  final myControllerDesc = TextEditingController();
  final myControllerPrice = TextEditingController();

  String? kategori;
  String? urunAdi;
  int? cip;
  String? aciklama;
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
  bool nextPage = false;
  int page = 0;
  int coin = 0;

  @override
  void dispose() {
    myControllerName.dispose();
    myControllerDesc.dispose();
    myControllerPrice.dispose();
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white.withOpacity(.95),
          body: buildPageName(context,
              size), //buildProductPrice(size)//buildProductDescription(context, size) //buildPageCategory(size)//buildPageName(context, size,page),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if (page == 0) {
      return true;
    } else {
      setState(() {
        page = page - 1;
      });
      return false;
    }
  }

  void _showAlert() {
    AlertDialog dialog = new AlertDialog(
      content: Container(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("İlanın yükleniyor..."),
            SizedBox(
              width: 10,
            ),
            CircularProgressIndicator(
                backgroundColor: kPrimaryColor,
                valueColor: AlwaysStoppedAnimation<Color>(kSecondaryColor)),
          ],
        ),
      )),
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: dialog);
        });
  }

  Container buildPageName(
    BuildContext context,
    Size size,
  ) {
    if (page == 0) {
      return Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black.withOpacity(.8),
                  ),
                  myControllerName.text.isEmpty
                      ? RaisedButton(
                          onPressed: null,
                          disabledColor: kPrimaryColor.withOpacity(0.5),
                          color: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "İleri",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        )
                      : RaisedButton(
                          onPressed: () {
                            print(myControllerName.text);
                            urunAdi = myControllerName.text;
                            setState(() {
                              page = page + 1;
                            });
                          },
                          //disabledColor: kPrimaryColor.withOpacity(0.5),
                          color: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "İleri",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: size.height * .2),
              child: Center(
                child: Text(
                  "İlanına isim ver",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getProportionateScreenWidth(25),
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: getProportionateScreenWidth(15)),
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(width: 1, color: Colors.grey[300]!),
                    bottom: BorderSide(width: 1, color: Colors.grey[300]!)),
              ),
              child: TextField(
                controller: myControllerName,
                onChanged: (text) {
                  if (text.length == 0) {
                    setState(() {
                      if (nextPage) {
                        nextPage = false;
                      }
                    });
                  }
                  if (text.length != 0) {
                    setState(() {
                      if (!nextPage) {
                        nextPage = true;
                      }
                    });
                  }
                },
                cursorColor: Colors.black.withOpacity(.6),
                keyboardType: TextInputType.text,
                maxLines: null,
                autofocus: false,
                cursorWidth: 1.1,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 15, top: 15, right: 15),
                    hintStyle: TextStyle(color: Colors.grey),
                    hintText: 'İlanına isim ver'),
              ),
            )
          ],
        ),
      );
    } else if (page == 1) {
      return buildCategoryScreen(size);
    } else if (page == 2) {
      return buildDescriptionScreen(context, size);
    } else if (page == 3) {
      return buildPriceScreen(size);
    }
    return Container();
  }

  Container buildPriceScreen(Size size) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        page = page - 1;
                      });
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black54,
                    )),
                myControllerPrice.text.length == 0
                    ? RaisedButton(
                        onPressed: null,
                        disabledColor: kPrimaryColor.withOpacity(0.5),
                        color: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "İleri",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      )
                    : RaisedButton(
                        onPressed: () async {
                          _showAlert();
                          cip = coin;
                          print("Ürün Adı: $urunAdi");
                          print("Ürün Açıklama $aciklama");
                          print("Ürün Çip $cip");
                          print("Ürün Kategori $kategori");
                          print("Resim Sayısı" +
                              widget.images!.length.toString());
                          Product product = new Product();
                          product.description = aciklama;
                          product.category = kategori;
                          product.title = urunAdi;
                          product.cip = cip;
                          List<File> list = [];
                          for (String a in widget.images!) {
                            list.add(File(a));
                          }
                          UserNotifier userNotifier =
                              Provider.of<UserNotifier>(context, listen: false);
                          Product? created =
                              await createProduct(userNotifier, product, list);
                          print("CREATED PRODUCTTTTTT ::::::: !!!!!! " +
                              created!.toMapwithId().toString());

                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return ProductDetail(
                                isUserOwner: true,
                                product: created,
                                productOwner: userNotifier.CurrentUser!);
                          }));

                          /* Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext context) {
                      return ProductDetail();
                    }));*/
                          //print("asadasdasdadsadsasdasdasdasdasdasdasd");
                          //işin bittiği yer
                          /*Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext context) {
                      return ProductCategory(images:widget.images,productName: myController.text,);
                    }));*/
                        },
                        //disabledColor: kPrimaryColor.withOpacity(0.5),
                        color: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "İleri",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: size.height * .2),
            child: Center(
              child: Text(
                "Fiyat Gir",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(25),
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: getProportionateScreenWidth(15)),
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(width: 1, color: Colors.grey[300]!),
                  bottom: BorderSide(width: 1, color: Colors.grey[300]!)),
            ),
            child: TextField(
              controller: myControllerPrice,
              onChanged: (text) {
                print(text.length);
                if (text.length == 0) {
                  setState(() {});
                }
                if (text.length != 0) {
                  //myController.text ="₺"+text.toString();
                  print(coin.toString());
                  setState(() {
                    coin = int.parse(text.toString()) * 17.6.round();
                  });
                }
              },
              cursorColor: Colors.black.withOpacity(.6),
              keyboardType: TextInputType.number,
              autofocus: false,
              maxLines: null,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              /* <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],*/
              cursorWidth: 1.1,
              decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      "assets/images/tlsimge.png",
                      height: 6,
                      width: 6,
                    ),
                  ),
                  suffixIcon: myControllerPrice.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SvgPicture.asset(
                            "assets/icons/coin.svg",
                            width: 16,
                            height: 16,
                          ),
                        )
                      : Container(),
                  suffix: myControllerPrice.text.isNotEmpty
                      ? Text("$coin çip")
                      : Container(),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 15, top: 15, right: 15),
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: 'Fiyat Gir'),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Text(
              "Ürünün için gerçekçi bir fiyat belirle ve biz sana kaç çip edeceğini söyleyelim.Diger kullanıcılar bu fiyatı göremezler.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  Container buildDescriptionScreen(BuildContext context, Size size) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        page = page - 1;
                      });
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black.withOpacity(.8),
                    )),
                myControllerDesc.text.isEmpty
                    ? RaisedButton(
                        onPressed: null,
                        disabledColor: kPrimaryColor.withOpacity(0.5),
                        color: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "İleri",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      )
                    : RaisedButton(
                        onPressed: () {
                          aciklama = myControllerDesc.text;
                          setState(() {
                            page = page + 1;
                          });
                          /*Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext context) {
                      return ProductCategory(images:widget.images,productName: myControllerDesc.text,);
                    }));*/
                        },
                        //disabledColor: kPrimaryColor.withOpacity(0.5),
                        color: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "İleri",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: size.height * .2),
            child: Center(
              child: Text(
                "İlanını Açıkla",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(25),
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: getProportionateScreenWidth(15)),
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(width: 1, color: Colors.grey[300]!),
                  bottom: BorderSide(width: 1, color: Colors.grey[300]!)),
            ),
            child: TextField(
              controller: myControllerDesc,
              onChanged: (text) {
                if (text.length == 0) {
                  setState(() {
                    if (nextPage) {
                      nextPage = false;
                    }
                  });
                }
                if (text.length != 0) {
                  setState(() {
                    if (!nextPage) {
                      nextPage = true;
                    }
                  });
                }
              },
              cursorColor: Colors.black.withOpacity(.6),
              keyboardType: TextInputType.text,
              maxLines: null,
              autofocus: false,
              cursorWidth: 1.1,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 15, top: 15, right: 15),
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: 'İlanını Açıkla'),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "İlanını tanımlayan ve ürünün durumunu belirten açıklama yaz",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Container buildCategoryScreen(Size size) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        page = page - 1;
                      });
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black.withOpacity(.8),
                    )),
                RaisedButton(
                  onPressed: null,
                  disabledColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: getProportionateScreenWidth(20)),
            child: Center(
              child: Text(
                "Ürün Kategorisi",
                style: TextStyle(
                    color: Colors.black.withOpacity(.8),
                    fontWeight: FontWeight.w600,
                    fontSize: getProportionateScreenWidth(25)),
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenWidth(25),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: categories.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    //return MakeCategory(size: size,categoryName: categories[index].toString(),);
                    return BunuDene(
                        context, size, categories[index].toString());
                  }))
        ],
      ),
    );
  }

  Widget BunuDene(BuildContext context, Size size, String categoryName) {
    return InkWell(
      onTap: () {
        kategori = categoryName;
        print(categoryName);
        setState(() {
          page = page + 1;
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: getProportionateScreenWidth(0.1)),
        width: size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 1, color: Colors.grey[300]!),
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
                "$categoryName",
                style: TextStyle(
                    color: Colors.black.withOpacity(.8), fontSize: 16),
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
