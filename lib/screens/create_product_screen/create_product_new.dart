import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/product_detail/product_detail.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:takasla/size_config.dart';

class CCreateProduct extends StatefulWidget {
  const CCreateProduct({Key? key}) : super(key: key);

  @override
  _CCreateProductState createState() => _CCreateProductState();
}

class _CCreateProductState extends State<CCreateProduct> {
  final CurrencyTextInputFormatter formatter =
      CurrencyTextInputFormatter(locale: 'tr');
  TextEditingController _productNameController = new TextEditingController();
  TextEditingController _productDescController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _productCategoryController =
      new TextEditingController();
  TextEditingController _productCipController = new TextEditingController();
  final _createProductKey = GlobalKey<FormState>();
  List<File> imagesLocalList = [];
  List<String> deletedImgList = [];
  final picker = ImagePicker();
  int maxLengthAd = 50;
  int textLenght = 0;
  int maxLengthDesc = 100;
  int textLengthDesc = 0;
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
  int coin = 0;

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
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shape: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(.3), width: 1)),
        title: Text(
          "İlan oluştur",
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (_createProductKey.currentState!.validate() &&
                imagesLocalList.length != 0) {
              print("Ürün Adı: " + _productNameController.text);
              print("Ürün Açıklama: " + _productDescController.text);
              print("Ürün Kategori: " + _productCategoryController.text);
              print("Ürün Fiyat: " +
                  (formatter.getUnformattedValue() * (1.2)).round().toString());
              print("Resim Sayısı: " + imagesLocalList.length.toString());
              Product product = new Product();
              product.description = _productDescController.text;
              product.category = _productCategoryController.text;
              product.title = _productNameController.text;
              product.cip = (formatter.getUnformattedValue() * (1.2)).round();
              /*List<File> list = [];
              for (String a in widget.images!) {
                list.add(File(a));
              }*/
              Product? created = await createProduct(
                  Provider.of<UserNotifier>(context, listen: false),
                  product,
                  imagesLocalList);
              print("CREATED PRODUCTTTTTT ::::::: !!!!!! " +
                  created!.toMapwithId().toString());
              Navigator.of(context).pushReplacement(PageTransition(
                  child: ProductDetail(
                      isUserOwner: true,
                      product: created,
                      productOwner:
                          Provider.of<UserNotifier>(context, listen: false)
                              .CurrentUser!),
                  type: PageTransitionType.rightToLeft));
            } else if (imagesLocalList.isEmpty) {
              _scaffoldKey.currentState!.showSnackBar(new SnackBar(
                  content: new Text("Ürüne ait en az bir fotoğraf yükleyin.")));
            }
            await Future<void>.delayed(const Duration(milliseconds: 1000));
          },
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15, bottom: 15, top: 15),
              child: Container(
                height: getProportionateScreenHeight(50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kPrimaryColor,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: getProportionateScreenHeight(12),
                      bottom: getProportionateScreenHeight(12)),
                  child: Center(
                      child: Text(
                    "Yayınla",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  )),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.grey.withOpacity(.35), width: 1)),
                color: Colors.white),
            child: Padding(
              padding:
                  EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
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
                      return Pictures(
                        context,
                        imagesLocalList[index - 1].path,
                        true,
                      );
                      /*if (imagesLocalList[index - 1] is File) {
                        return Pictures(
                          context,
                          imagesLocalList[index - 1].path,
                          true,
                        );
                      }*/
                      /*return Pictures(
                        context,
                        imagesLocalList[index - 1],
                        false,
                      );*/ //productNotifier.currentProduct.images[index-1],);
                    }),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .6),
            child: Form(
                key: _createProductKey,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Ürün adı giriniz";
                            }
                          },
                          controller: _productNameController,
                          maxLength: 50,
                          cursorWidth: 2.5,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: kPrimaryColor,
                          onChanged: (value) {
                            setState(() {
                              textLenght = value.length;
                            });
                          },
                          decoration: InputDecoration(
                              counterText: "",
                              suffixStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              suffixText: '${maxLengthAd - textLenght}',
                              fillColor: Colors.grey.withOpacity(.1),
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              floatingLabelStyle:
                                  TextStyle(color: kPrimaryColor),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.5)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(.3),
                                    width: 1),
                              ),
                              border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              labelText: "Ürün adı*",
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        Container(
                          height: getProportionateScreenHeight(20),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Ürün açıklaması giriniz";
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              textLengthDesc = value.length;
                            });
                          },
                          controller: _productDescController,
                          maxLength: 100,
                          cursorWidth: 2.5,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                              counterText: "",
                              suffixStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              suffixText: '${maxLengthDesc - textLengthDesc}',
                              fillColor: Colors.grey.withOpacity(.1),
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              floatingLabelStyle:
                                  TextStyle(color: kPrimaryColor),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.5)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(.3),
                                    width: 1),
                              ),
                              border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              labelText: "Açıklama*",
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        Container(
                          height: getProportionateScreenHeight(20),
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    showCategoryDialog(context));
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Kategori seçiniz";
                                }
                              },
                              readOnly: true,
                              controller: _productCategoryController,
                              cursorWidth: 2.5,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.withOpacity(.1),
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  floatingLabelStyle:
                                      TextStyle(color: kPrimaryColor),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: kPrimaryColor, width: 2.5)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(.3),
                                        width: 1),
                                  ),
                                  border: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  labelText: "Kategori*",
                                  labelStyle: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        ),
                        Container(
                          height: getProportionateScreenHeight(20),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Fiyat giriniz";
                            }
                          },
                          onChanged: (text) {
                            setState(() {
                              coin = (formatter.getUnformattedValue() * (1.2))
                                  .round();
                            });
                            /*if (text.length >= 3) {
                          //myController.text ="₺"+text.toString();
                          //print(coin.toString());
                          setState(() {
                            /*coin = int.parse(fiyat) * 17.6.round();
                            print(coin);*/
                          });
                        }*/
                          },
                          inputFormatters: [formatter],
                          controller: _productCipController,
                          cursorWidth: 2.5,
                          keyboardType: TextInputType.numberWithOptions(),
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                              suffixIcon: _productCipController.text.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: SvgPicture.asset(
                                        "assets/icons/coin.svg",
                                        width: 16,
                                        height: 16,
                                      ),
                                    )
                                  : null,
                              suffix: _productCipController.text.isNotEmpty
                                  ? Text("$coin çip")
                                  : null,
                              fillColor: Colors.grey.withOpacity(.1),
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              floatingLabelStyle:
                                  TextStyle(color: kPrimaryColor),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.5)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(.3),
                                    width: 1),
                              ),
                              border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              labelText: "Fiyat*",
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                        Container(
                          height: 5,
                        ),
                        Text(
                          "Ürünün için gerçekçi bir fiyat belirle ve biz sana kaç çip edeceğini söyleyelim. Diğer kullanıcılar bu fiyatı göremezler.",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ],
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
                height: 5,
              ),
              Text(
                "Ürün Kategorisi",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(20),
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: categories.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        //return MakeCategory(size: size,categoryName: categories[index].toString(),);
                        return BunuDene(context, categories[index].toString());
                      }))
            ],
          ),
        ),
      ),
    );
  }

  Widget BunuDene(BuildContext context, String categoryName) {
    return InkWell(
      onTap: () {
        setState(() {
          _productCategoryController.text = categoryName;
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
            color: Colors.grey[100],
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
