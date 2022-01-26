import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/services/api/takasla_api.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  UserNotifier? userNotifier;
  User? crntUser;
  File? newImg;
  final myControllerName = TextEditingController();
  final picker = ImagePicker();

  @override
  void initState() {
    userNotifier = Provider.of<UserNotifier>(context, listen: false);
    myControllerName.text = userNotifier!.CurrentUser!.displayName!;
    crntUser = new User.fromMap(userNotifier!.CurrentUser!.toMap());
    super.initState();
  }

  @override
  void dispose() {
    newImg = null;
    super.dispose();
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        var _image = File(pickedFile.path);
        newImg = _image;
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
        newImg = _image;

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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_ios)),
        actions: [
          Padding(
            padding:
                EdgeInsets.only(bottom: 12.0, right: 12, left: 12, top: 13),
            child: RaisedButton(
              onPressed: () async {
                if (newImg == null &&
                    myControllerName.text == crntUser!.displayName) {
                  Navigator.of(context).pop();
                } else {
                  if (newImg != null) {
                    String? photoUrl =
                        await uploadSingleImage(newImg!, userNotifier!);
                    crntUser!.photoUrl = photoUrl;
                  }
                  if (myControllerName.text != crntUser!.displayName) {
                    crntUser!.displayName = myControllerName.text;
                  }
                  await updateUser(userNotifier!, crntUser!);
                  Navigator.of(context).pop();
                }
              },
              disabledColor: kPrimaryColor.withOpacity(0.5),
              color: kPrimaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                "Kaydet",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () {
                      showPopUp(context);
                    },
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: newImg != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: FileImage(
                                newImg!), //NetworkImage(userNotifier!.CurrentUser!.photoUrl!),

                            //newImg ==null ?
                            //NetworkImage(userNotifier!.CurrentUser!.photoUrl!)
                            //:FileImage(newImg!),*/
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                                userNotifier!.CurrentUser!.photoUrl!),

                            //newImg ==null ?
                            //NetworkImage(userNotifier!.CurrentUser!.photoUrl!)
                            //:FileImage(newImg!),*/
                          )),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 25),
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
                  if (text.length == 0) {
                    setState(() {});
                  }
                  if (text.length != 0) {
                    setState(() {});
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
              height: 10,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "Adını gir",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showPopUp(BuildContext context) {
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
}
