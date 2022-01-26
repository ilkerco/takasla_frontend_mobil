import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/product_detail/product_detail.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:takasla/size_config.dart';

class EditProduct extends StatefulWidget {
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final myControllerName = TextEditingController();
  final myControllerDescription = TextEditingController();
  final myControllerPrice = TextEditingController();
  List<dynamic> imagesLocalList = [];
  UserNotifier? userNotifier;
  ProductNotifier? productNotifier;
  List<String> deletedImgList = [];
  final picker = ImagePicker();
  String? urunAdi, urunAciklamasi, urunKategori;
  Product? currentProduct;
  User? currentUser;
  int? cip;
  int? coin;
  int? price;
  bool errorName = false;
  bool errorDesc = false;
  bool errorPrice = false;
  Size? size;
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

  @override
  void dispose() {
    imagesLocalList = [];
    deletedImgList = [];
    super.dispose();
  }

  @override
  void initState() {
    productNotifier = Provider.of<ProductNotifier>(context, listen: false);
    userNotifier = Provider.of<UserNotifier>(context, listen: false);

    currentProduct = new Product.fromMap(
        productNotifier!.GetCurrentProduct()!.toMapwithId());
    for (String i in currentProduct!.images!) {
      imagesLocalList.add(i);
    }
    currentUser = userNotifier!.CurrentUser;
    urunAdi = productNotifier!.GetCurrentProduct()!.title;
    urunAciklamasi = productNotifier!.GetCurrentProduct()!.description;
    urunKategori = productNotifier!.GetCurrentProduct()!.category;
    cip = productNotifier!.GetCurrentProduct()!.cip;
    coin = cip;
    price = (cip! / 17.6).round();
    myControllerName.text = urunAdi!;
    myControllerDescription.text = urunAciklamasi!;
    myControllerPrice.text = price.toString();
    super.initState();
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        var _image = File(pickedFile.path);
        imagesLocalList.add(_image);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        var _image = File(pickedFile.path);
        print(pickedFile.path);
        imagesLocalList.add(_image);

        if (_image is File) {
          print("file Image");
        }
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<ProductNotifier>(
        builder: (context, productNotifier, _) => Scaffold(
          backgroundColor: Colors.grey[200],
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                centerTitle: false,
                pinned: true,
                floating: false,
                expandedHeight: 140,
                backgroundColor: Colors.grey[200],
                leading: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black54,
                    size: 28,
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 12.0, right: 12, left: 12, top: 13),
                    child: RaisedButton(
                      onPressed: () async {
                        if (imagesLocalList.length == 0) {
                          final snackBar = SnackBar(
                            content: Text(
                              'Yetersiz fotoğraf',
                              textAlign: TextAlign.center,
                            ),
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else {
                          List<File> img2upload = [];
                          if (deletedImgList.length > 0) {
                            for (String imgPath_ in deletedImgList) {
                              await deleteSingleImage(
                                  imgPath_, currentUser!.accessToken!);
                            }
                          }
                          for (var obj in imagesLocalList) {
                            if (obj is File) {
                              img2upload.add(obj);
                            }
                          }
                          print(img2upload);
                          currentProduct!.title = urunAdi;
                          currentProduct!.description = urunAciklamasi;
                          currentProduct!.category = urunKategori;
                          currentProduct!.cip = cip;
                          /*await uploadProductAndImages(currentProduct,
                              currentUser, true, img2upload, productNotifier);
                          //await getProducts(productNotifier,userNotifier);
                          deletedImgList = [];
                          print(productNotifier.currentProduct
                              .toMap()
                              .toString());
                          await getProducts(productNotifier, userNotifier);*/

                          Product updatedProduct = await updateProduct(
                              currentProduct!,
                              currentUser!,
                              productNotifier,
                              img2upload);

                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                isUserOwner: true,
                                product: updatedProduct,
                                productOwner: currentUser!,
                              ),
                            ),
                          );
                        }
                      },
                      disabledColor: kPrimaryColor.withOpacity(0.5),
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Kaydet",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                      child: Text(
                    "İlanın yayınlandı, ürünün detaylarını ekleyebilirsin",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  )),
                  collapseMode: CollapseMode.pin,
                  centerTitle: true,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: Colors.grey.withOpacity(.35),
                                  width: 1),
                              bottom: BorderSide(
                                  color: Colors.grey.withOpacity(.35),
                                  width: 1)),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 15, bottom: 15, left: 10, right: 10),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          //margin:EdgeInsets.only(top: 10,left: 5,right: 10),
                          height: 70,
                          child: ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: imagesLocalList.length +
                                  1, //productNotifier.currentProduct.images.length+1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return Picture(context);
                                }
                                if (imagesLocalList[index - 1] is File) {
                                  return Pictures(
                                    context,
                                    imagesLocalList[index - 1].path,
                                    true,
                                  );
                                }
                                return Pictures(
                                  context,
                                  imagesLocalList[index - 1],
                                  false,
                                ); //productNotifier.currentProduct.images[index-1],);
                              }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        //showTitleDialog(context);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                showTitleDialog(context));
                      },
                      child: Ink(
                        color: Colors.white,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1),
                                bottom: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, top: 15, bottom: 15, right: 10),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ürün adı",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 45.0),
                                      child: Text(
                                        urunAdi!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                showDescDialog(context));
                      },
                      child: Ink(
                        color: Colors.white,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1),
                                bottom: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, top: 15, bottom: 15, right: 10),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ürün açıklaması",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 45.0),
                                      child: Text(
                                        urunAciklamasi!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                showCategoryDialog(context));
                      },
                      child: Ink(
                        color: Colors.white,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1),
                                bottom: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, top: 15, bottom: 15, right: 10),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Kategori",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 45.0),
                                      child: Text(
                                        urunKategori!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                return showPriceDialog(context, setState);
                              });
                            });
                      },
                      child: Ink(
                        color: Colors.white,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1),
                                bottom: BorderSide(
                                    color: Colors.grey.withOpacity(.35),
                                    width: 1)),
                          ),
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10, top: 15, bottom: 15, right: 10),
                              child: Row(
                                children: [
                                  //sol taraf
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Fiyat,"),
                                              Image.asset(
                                                "assets/images/tlsimge.png",
                                                width: 12,
                                                height: 12,
                                                color: kSecondaryColor,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            price.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 60,
                                    width: 1,
                                    color: Colors.grey.withOpacity(.35),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  //sağ taraf
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Çip değeri"),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/coin.svg",
                                                height: 15,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                cip.toString() + " çip",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 16),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void shopPopUp(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (builder) {
          return Container(
              height: getProportionateScreenWidth(100),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              //height: MediaQuery.of(context).size.height * .45,
              padding: EdgeInsets.only(top: 20, left: 30, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      print("Edit");
                      //Take Photo from Camera
                      /*Navigator.of(context)
                          .push(MaterialPageRoute(builder: (BuildContext context) {
                        return EditProduct();
                      }));*/
                      await getImageFromCamera();
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Fotoğraf çek",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    splashColor: kPrimaryColor,
                    onTap: () async {
                      print("Essdit");
                      //Pick Image From Gallery
                      /*Navigator.of(context)
                          .push(MaterialPageRoute(builder: (BuildContext context) {
                        return EditProduct();
                      }));*/
                      await getImageFromGallery();

                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image_aspect_ratio_outlined),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Galeriden seç",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }

  showPriceDialog(BuildContext context, setState) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.grey[200], //this right here
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * .8,
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    RaisedButton(
                      onPressed: () {
                        print(myControllerPrice.text);
                        /*Navigator.of(context)
                            .push(MaterialPageRoute(builder: (BuildContext context) {
                          return ProductCategory(images:widget.images,productName: myController.text,);
                        }));*/
                        if (myControllerPrice.text.isEmpty) {
                          setState(() {
                            errorPrice = true;
                          });
                        } else {
                          setState(() {
                            cip = coin;
                            price = int.parse(myControllerPrice.text);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      //disabledColor: kPrimaryColor.withOpacity(0.5),
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Kaydet",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Text(
                "Fiyat gir",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(20),
                    fontWeight: FontWeight.w700),
              ),
              Container(
                margin: EdgeInsets.only(top: getProportionateScreenWidth(15)),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Colors.grey.withOpacity(.35), width: 1),
                      bottom: BorderSide(
                          color: Colors.grey.withOpacity(.35), width: 1)),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: myControllerPrice,
                  onChanged: (text) {
                    print(text.length);
                    if (text.length == 0) {
                      setState(() {
                        if (!errorPrice) {
                          errorPrice = true;
                        }
                        coin = 0;
                      });
                    }
                    if (text.length != 0) {
                      //myController.text ="₺"+text.toString();
                      setState(() {
                        if (errorPrice) {
                          errorPrice = false;
                        }
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
                      /*suffixIcon: myControllerPrice.text.isNotEmpty?Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SvgPicture.asset("assets/icons/coin.svg",width: 16,height: 16,),
                      ) :Container(),*/
                      //suffix: myControllerPrice.text.isNotEmpty?Text("$coin çip"):Container(color: Colors.black,),
                      suffix: Text("$coin çip"),
                      suffixIcon: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SvgPicture.asset(
                            "assets/icons/coin.svg",
                            width: 16,
                            height: 16,
                          )),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 15, top: 15, right: 15),
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Fiyat Gir'),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              errorPrice
                  ? Text(
                      "Fiyat alanı boş bırakılamaz.",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  showTitleDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.grey[200], //this right here
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * .8,
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    RaisedButton(
                      onPressed: () {
                        print(myControllerName.text);
                        /*Navigator.of(context)
                            .push(MaterialPageRoute(builder: (BuildContext context) {
                          return ProductCategory(images:widget.images,productName: myController.text,);
                        }));*/
                        if (myControllerName.text.isEmpty) {
                          setState(() {
                            errorName = true;
                          });
                        } else {
                          setState(() {
                            urunAdi = myControllerName.text;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      //disabledColor: kPrimaryColor.withOpacity(0.5),
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Kaydet",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Text(
                "İlanına isim ver",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(20),
                    fontWeight: FontWeight.w700),
              ),
              Container(
                margin: EdgeInsets.only(top: getProportionateScreenWidth(15)),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(width: 1, color: Colors.grey[300]!),
                      bottom: BorderSide(width: 1, color: Colors.grey[300]!)),
                ),
                child: TextField(
                  controller: myControllerName,
                  onChanged: (text) {
                    if (text.isEmpty) {
                      if (!errorName) {
                        setState(() {
                          errorName = true;
                        });
                      }
                    } else {
                      if (errorName) {
                        setState(() {
                          errorName = false;
                        });
                      }
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
              ),
              SizedBox(
                height: 15,
              ),
              errorName
                  ? Text(
                      "İlan adı boş bırakılamaz.",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  showDescDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.grey[200], //this right here
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * .8,
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    RaisedButton(
                      onPressed: () {
                        print(myControllerDescription.text);
                        /*Navigator.of(context)
                            .push(MaterialPageRoute(builder: (BuildContext context) {
                          return ProductCategory(images:widget.images,productName: myController.text,);
                        }));*/
                        if (myControllerDescription.text.isEmpty) {
                          setState(() {
                            errorDesc = true;
                          });
                        } else {
                          setState(() {
                            urunAciklamasi = myControllerDescription.text;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      //disabledColor: kPrimaryColor.withOpacity(0.5),
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Kaydet",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Text(
                "İlanını Açıkla",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(20),
                    fontWeight: FontWeight.w700),
              ),
              Container(
                margin: EdgeInsets.only(top: getProportionateScreenWidth(15)),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(width: 1, color: Colors.grey[300]!),
                      bottom: BorderSide(width: 1, color: Colors.grey[300]!)),
                ),
                child: TextField(
                  controller: myControllerDescription,
                  onChanged: (text) {
                    if (text.isEmpty) {
                      if (!errorDesc) {
                        setState(() {
                          errorDesc = true;
                        });
                      }
                    } else {
                      if (errorDesc) {
                        setState(() {
                          errorDesc = false;
                        });
                      }
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
                      hintText: 'İlanını açıkla'),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              errorDesc
                  ? Text(
                      "İlan açıklaması boş bırakılamaz.",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  showCategoryDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.grey[200], //this right here
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * .8,
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Ürün Kategorisi",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(20),
                    fontWeight: FontWeight.w700),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: categories.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        //return MakeCategory(size: size,categoryName: categories[index].toString(),);
                        return BunuDene(
                            context, size!, categories[index].toString());
                      }))
            ],
          ),
        ),
      ),
    );
  }

  Widget BunuDene(BuildContext context, Size size, String categoryName) {
    return InkWell(
      onTap: () {
        setState(() {
          urunKategori = categoryName;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        margin: EdgeInsets.only(top: getProportionateScreenWidth(0.1)),
        //width: size.width,
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

  Widget Pictures(BuildContext context, String imgPath, bool isFile) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 3),
      child: InkWell(
        onTap: () {
          print("Var olan image");
          shopPopUpDelete(context, imgPath, isFile);
        },
        child: Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            image: !isFile
                ? DecorationImage(
                    image: NetworkImage(imgPath),
                    fit: BoxFit.cover,
                  )
                : DecorationImage(
                    image: FileImage(File(imgPath)),
                    fit: BoxFit.cover,
                  ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  void shopPopUpDelete(BuildContext context, String imgPath, bool isFile) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (builder) {
          return Container(
              height: getProportionateScreenWidth(75),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              //height: MediaQuery.of(context).size.height * .45,
              padding: EdgeInsets.only(top: 20, left: 30, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      if (isFile) {
                        print("is file");
                        var deleted;
                        for (var ss in imagesLocalList) {
                          if (ss is File && ss.path == imgPath) {
                            deleted = ss;
                          }
                        }

                        setState(() {
                          imagesLocalList.remove(deleted);
                        });
                      } else {
                        //delete from db
                        print("Delete Image From Db");
                        print(imgPath);
                        deletedImgList.add(imgPath);
                        setState(() {
                          imagesLocalList.remove(imgPath);
                        });

                        //await deleteSingleImage(imgPath,currentUser.accessToken);
                        //Del Image From Db
                        /*Navigator.of(context)
                          .push(MaterialPageRoute(builder: (BuildContext context) {
                        return EditProduct();
                      }));*/
                      }
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Sil",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }

  Widget Picture(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, left: 5),
      child: InkWell(
        onTap: () {
          shopPopUp(context);
        },
        child: Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            Icons.camera_alt,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
