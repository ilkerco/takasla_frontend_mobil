import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/screens/ilanlar_screen/ilanlar_screen.dart';
import 'package:takasla/size_config.dart';
import 'package:takasla/notifiers/image_notifier.dart';
import 'package:takasla/screens/create_product_screen/create_product.dart';

import 'camera_example_home.dart';

/*class CameraPage extends StatelessWidget {
  CameraPage(this.cameras);
  final List<CameraDescription> cameras;
  @override
  Widget build(BuildContext context) {
    return CameraExampleHome(cameras);
  }
}*/

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraPage({Key? key, required this.cameras}) : super(key: key);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late ImageNotifier _imageNotifier;
  late Future<void> _initializeControllerFuture;
  late CameraController controller;
  bool _isCameraInitialized = false;
  bool _isCameraOn = true;
  List<String> imgList = [];
  late List<CameraDescription> _availableCameras;
  bool flash = false;
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    //SystemChrome.setEnabledSystemUIOverlays([]);
    _initCameraController();
    //onNewCameraSelected(widget.cameras[0]);
    _imageNotifier = Provider.of<ImageNotifier>(this.context, listen: false);
    //_imageNotifier.imagesList.clear();
    _imageNotifier.clearCurrentImage();

    //WidgetsBinding.instance.addObserver(this);
    print("kamera açıldı");
    super.initState();

    //_getAvailableCameras();
  }

  _initCameraController() async {
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      await cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      await onNewCameraSelected(cameraController.description);
    }
    /*if (state == AppLifecycleState.resumed) {
      print("devam edildi **********************************");
      _getAvailableCameras();
    } else if (state == AppLifecycleState.inactive) {
      print("inactiveeeee olduuuuuuuuuuu*********");
      controller?.dispose();
    }*/
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    if (mounted) {
      setState(() {});
    }

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }

    await previousCameraController.dispose();
  }

  /*Future<void> _getAvailableCameras() {
    print("geldi");
    WidgetsFlutterBinding.ensureInitialized();
    _availableCameras = widget.cameras;
    _initCamera(_availableCameras.first);
  }*/

  Future<void> _initCamera(CameraDescription description) async {
    print("INITING CAMERA");
    controller = CameraController(description, ResolutionPreset.low);
    try {
      await controller.initialize();
      if (!mounted) {
        return;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _captureImage(ImageNotifier _imageNotifier) async {
    final path =
        join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
    final picture = await controller.takePicture();
    picture.saveTo(path);

    //final File imgFile = File(path);
    //_imageNotifier.addImage(path);
    setState(() {
      imgList.add(path);
    });
  }

  Future getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imgList.add(pickedFile.path);
      }
    });
  }

  void _toggleCameraLens() {
    final lensDirection = controller.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _availableCameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _availableCameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }
    if (newDescription != null) {
      _initCamera(newDescription);
    } else {
      print("İstenilen kamera bulunamadı");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    //imageNotifier.currentImage = null;
    //Provider.of<ImageNotifier>(this.context, listen: false).currentImage = null;
    controller.dispose();
    print(
        "KAMERA PAGE KAPANDIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII**************************");
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    //print(controller);
    super.dispose();
  }

  Widget _cameraPreviewWigdet() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(
        controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //ImageNotifier imageNotifier = Provider.of<ImageNotifier>(context, listen: false);
    final CameraController cameraController = controller;
    /*if (!cameraController.value.isInitialized || cameraController == null) {
      return Container(
        child: Center(child: Text("Could not connect to camera.")),
      );
    }*/
    return FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<ImageNotifier>(
              builder: (context, imageNotifier, _) => SafeArea(
                child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Container(
                      child: Stack(
                        children: [
                          imageNotifier.GetCurrentImage() == null
                              ? _cameraPreviewWigdet() //CameraPreview(controller)
                              : Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: double.infinity,
                                    height:
                                        MediaQuery.of(context).size.height * .8,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: FileImage(File(
                                                imageNotifier.GetCurrentImage()
                                                    .toString())),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .8,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black38),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        imgList.length > 0
                                            ? RaisedButton(
                                                onPressed: () {
                                                  //controller?.dispose();
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                    return CreateProduct(
                                                      images: imgList,
                                                    );
                                                  }));
                                                  /*.then((value) => {
                                                  SystemChrome
                                                      .setEnabledSystemUIOverlays(
                                                          []),
                                                  _getAvailableCameras(),
                                                  print(
                                                      "Kmaera sayfasına geri gelindi")
                                                });*/
                                                },
                                                disabledColor: kPrimaryColor
                                                    .withOpacity(0.5),
                                                color: kPrimaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Text(
                                                  "İleri",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 16),
                                                ),
                                              )
                                            : RaisedButton(
                                                onPressed: null,
                                                disabledColor: kPrimaryColor
                                                    .withOpacity(0.5),
                                                color: kPrimaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Text(
                                                  "İleri",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 16),
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                  imageNotifier.GetCurrentImage() == null
                                      ? Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Container(
                                              margin: EdgeInsets.only(
                                                  top: 5, bottom: 0),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .5,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        //size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height*.5,),
                                                        painter: MyPainter(0),
                                                      ),
                                                      CustomPaint(
                                                        painter: MyPainter(1),
                                                      )
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CustomPaint(
                                                            painter:
                                                                MyPainter(2),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        painter: MyPainter(3),
                                                      ),
                                                      CustomPaint(
                                                        painter: MyPainter(4),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )),
                                        )
                                      : Container(),
                                  imageNotifier.GetCurrentImage() == null
                                      ? Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .1,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: Text(
                                                    "Objeyi çerçevenin içinde tutun.",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 18.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          flash = !flash;
                                                        });
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: Container(
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child: flash
                                                                  ? Icon(
                                                                      Icons
                                                                          .flash_on,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 28,
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .flash_off,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 28,
                                                                    ))),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Material(
                              child: Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                color: Colors.grey[100],
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      left: 0,
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 10.0),
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  InkWell(
                                                      onTap: () {
                                                        getImageFromGallery();
                                                      },
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 32,
                                                      )),
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                        splashColor:
                                                            kPrimaryColor
                                                                .withRed(255),
                                                        highlightColor:
                                                            kPrimaryColor
                                                                .withOpacity(
                                                                    .3),
                                                        onTap: () {
                                                          if (imageNotifier
                                                                  .GetCurrentImage() ==
                                                              null) {
                                                            _captureImage(
                                                                imageNotifier);
                                                          } else {
                                                            setState(() {
                                                              imgList.remove(
                                                                  imageNotifier
                                                                      .GetCurrentImage());
                                                              imageNotifier
                                                                  .clearCurrentImage();
                                                            });
                                                          }
                                                        },
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        child: Container(
                                                            width: 70,
                                                            height: 70,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    kPrimaryColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            60)),
                                                            child: imageNotifier
                                                                        .GetCurrentImage() ==
                                                                    null
                                                                ? Icon(
                                                                    Icons
                                                                        .circle,
                                                                    size: 35,
                                                                    color:
                                                                        kPrimaryColor,
                                                                  )
                                                                : Icon(
                                                                    Icons
                                                                        .delete_forever,
                                                                    size: 35,
                                                                    color: Colors
                                                                        .white,
                                                                  ))),
                                                  ),
                                                  InkWell(
                                                      onTap: () {
                                                        _toggleCameraLens();
                                                      },
                                                      child: Icon(
                                                        Icons.switch_camera,
                                                        size: 32,
                                                      ))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.only(
                                            top: 10, left: 5, right: 10),
                                        height: getProportionateScreenWidth(60),
                                        child: ListView.builder(
                                            reverse: true,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: imgList.length + 1,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (index == 0) {
                                                return Picture();
                                              }
                                              return PictureDeneme(
                                                imgPath:
                                                    File(imgList[index - 1]),
                                              );
                                            }),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class Picture extends StatelessWidget {
  const Picture({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageNotifier imageNotifier =
        Provider.of<ImageNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, left: 10),
      child: InkWell(
        onTap: () {
          imageNotifier.clearCurrentImage();
        },
        child: Container(
          width: getProportionateScreenWidth(60),
          height: getProportionateScreenWidth(60),
          decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://i1.wp.com/angularscript.com/wp-content/uploads/2018/06/Progressively-Loading-Images-With-Blur-Effect-min.png?fit=800%2C455&ssl=1"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: kPrimaryColor, width: 3)),
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class PictureDeneme extends StatelessWidget {
  final File imgPath;
  const PictureDeneme({
    Key? key,
    required this.imgPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageNotifier imageNotifier =
        Provider.of<ImageNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 10),
      child: InkWell(
        onTap: () {
          imageNotifier.currentImage = imgPath.path;
          print("deneme deneme" + imageNotifier.GetCurrentImage().toString());
        },
        child: Container(
          width: getProportionateScreenWidth(60),
          height: getProportionateScreenWidth(60),
          decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(imgPath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: kPrimaryColor, width: 3)),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final int dot;

  MyPainter(this.dot);
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (dot == 0) {
      canvas.drawLine(Offset(0, 0), Offset(0, 30), paint);
      canvas.drawLine(Offset(0, 0), Offset(30, 0), paint);
    }
    if (dot == 1) {
      canvas.drawLine(Offset(0, 0), Offset(0, 30), paint);
      canvas.drawLine(Offset(0, 0), Offset(-30, 0), paint);
    }
    if (dot == 2) {
      canvas.drawLine(Offset(-15, 0), Offset(15, 0), paint);
      canvas.drawLine(Offset(0, -15), Offset(0, 15), paint);
    }
    if (dot == 3) {
      canvas.drawLine(Offset(0, 0), Offset(0, -30), paint);
      canvas.drawLine(Offset(0, 0), Offset(30, 0), paint);
    }
    if (dot == 4) {
      canvas.drawLine(Offset(0, 0), Offset(0, -30), paint);
      canvas.drawLine(Offset(0, 0), Offset(-30, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
