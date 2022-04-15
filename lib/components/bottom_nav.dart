import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:watermarking/views/login.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:scan/scan.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:watermarking/views/home.dart';

Future getOriginalImageURL(data) async {
  final response =
      await http.post("http://127.0.0.1:8000/api/getImage/", body: data);
  dynamic result = jsonDecode(response.body);
  result["status"] = response.statusCode;
  return result;
}

const double minHeight = 80;
const double iconStartSize = 44;
const double iconEndSize = 120;
const double iconStartMarginTop = 36;
const double iconEndMarginTop = 80;
const double iconsVerticalSpacing = 24;
const double iconsHorizontalSpacing = 16;

class BottomNav extends StatefulWidget {
  final bool openBottomNavBar;
  final bool userStatus;

  const BottomNav({Key key, this.openBottomNavBar = false, this.userStatus})
      : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  AnimationController _controller;
  List<Asset> images = <Asset>[];
  List<Asset> _selectedImages = <Asset>[];
  dynamic _selectedFiles = [];
  dynamic _path;
  String qrcode = 'Unknown';

  double get maxHeight => MediaQuery.of(context).size.height;
  double get headerTopMargin =>
      lerp(20, 20 + MediaQuery.of(context).padding.top);
  double get headerFontSize => lerp(14, 24);
  double get itemBorderRadius => lerp(8, 24);
  double get iconLeftBorderRadius => itemBorderRadius;
  double get iconRightBorderRadius => lerp(8, 0);
  double get iconSize => lerp(iconStartSize, iconEndSize);

  double iconTopMargin(int index) =>
      lerp(iconStartMarginTop,
          iconEndMarginTop + index * (iconsVerticalSpacing + iconEndSize)) +
      headerTopMargin;

  double iconLeftMargin(int index) =>
      lerp(index * (iconsHorizontalSpacing + iconStartSize), 0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    if (widget.openBottomNavBar == true) {
      _toggle();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value);

  Widget _buildSheetHeader({double fontSize, double topMargin}) {
    return Positioned(
      top: topMargin,
      child: Text(
        'Enlever des filigranes',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize * 1.1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          height: lerp(minHeight, maxHeight),
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 12),
              decoration: const BoxDecoration(
                color: Color(0xFF162A49),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: MediaQuery.of(context).size.width / 1.4,
                    right: 0,
                    bottom: MediaQuery.of(context).size.height / 23.2,
                    child: InkWell(
                      onTap: _toggle,
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.height / 29,
                      ),
                    ),
                  ),
                  _buildSheetHeader(
                    fontSize: headerFontSize,
                    topMargin: headerTopMargin,
                  ),
                  _buildExpandedEventItem(
                    topMargin: iconTopMargin(0),
                    leftMargin: iconLeftMargin(0),
                    height: iconSize,
                    isVisible: _controller.status == AnimationStatus.completed,
                    borderRadius: itemBorderRadius,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width / 3,
        decoration: BoxDecoration(color: Color(0xFF162A49)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  decoration: BoxDecoration(color: Color(0xFF162A49)),
                  height: MediaQuery.of(context).size.height / 7,
                  child: Stack(children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: Duration(
                          seconds: 1,
                        ),
                        curve: Curves.linear,
                        child: CircleAvatar(
                            backgroundColor: Color(0xFF162A49),
                            child: ClipOval(
                                child: Image.asset(
                              "assets/images/login.png",
                              fit: BoxFit.cover,
                            ))),
                      ),
                    )
                  ]))
            ]));
  }

  void _saveNetworkImage(path) async {
    GallerySaver.saveImage(path).then((bool success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Votre image a été sauvegardé.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFF44bd32)));
    });
  }

  wait() async {
    await Future.delayed(Duration(milliseconds: 2500));
  }

  Widget _buildScannerButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: MediaQuery.of(context).size.width / 1.3,
      child: FadeInUp(
        duration: Duration(milliseconds: 1000),
        child: MaterialButton(
          onPressed: () async {
            if (_path != "") {
              showSpinner(context, "scan en cours...");
              String result = await Scan.parse(_path);
              if (result != null) {
                var data = {"qrcode": result[0]};
                getOriginalImageURL(data).then((value) {
                  if (value["status"] == 200) {
                    var path = value["image"];
                    _saveNetworkImage(path);
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedFiles = [];
                      _selectedImages = [];
                      images = null;
                    });
                    wait();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => HomePage(
                              openBottomNavBar: false,
                            )));
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'Erreur lors du déchiffrage de l\'image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.red));
                  }
                });
              } else {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      'Echec! cette image ne contient pas de marque.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.red));
              }
            }
          },
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Color(0xff00a8ff),
          child: Row(
            children: [
              Icon(
                Icons.qr_code,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Scanner une image ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showSpinner(BuildContext context, dynamic content) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height / 179.2),
              child: Text(content)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> selectImages() async {
    if (_selectedFiles != null) {
      _selectedFiles.clear();
    }
    try {
      _selectedImages = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: false,
        selectedAssets: images,
        // cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Watermarking App",
          allViewTitle: "Toutes les photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );

      var path = await FlutterAbsolutePath.getAbsolutePath(
          _selectedImages[0].identifier);
      var _cmpressedFile =
          await FlutterImageCompress.compressWithFile(path, quality: 75);
      _selectedFiles.add(_cmpressedFile);
      this._path = path;
      return _selectedFiles;
    } catch (e) {
      print("Something wrong \n" + e.toString());
    }
  }

  getImages(context) {
    showSpinner(context, "chargement...");
    selectImages().then((_selectedFiles) {
      setState(() {
        _selectedFiles = _selectedFiles;
        Navigator.of(context).pop();
      });
    });
  }

  Widget _buildUploadSection() {
    return Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height / 54,
      ),
      Text(
        'Image depuis la galerie :',
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 55,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height / 81,
      ),
      GestureDetector(
        onTap: () {
          getImages(context);
        },
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 12.5,
                vertical: MediaQuery.of(context).size.height / 81),
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(10),
              dashPattern: [10, 4],
              strokeCap: StrokeCap.round,
              color: Colors.blue.shade400,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 5.5,
                decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(.3),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.image4,
                      color: Colors.blue,
                      size: MediaQuery.of(context).size.height / 20.3,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 54,
                    ),
                    Text(
                      'Choisissez votre image',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 54,
                          color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            )),
      ),
      _selectedFiles.length == 0
          ? const Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text("pas d'image sélectionnée!"),
            )
          : Container(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width / 5,
              child: Image.memory(
                _selectedFiles[0],
                fit: BoxFit.cover,
              ),
            ),
      _buildScannerButton()
    ]);
  }

  Widget _buildContent() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        FadeInDown(
            duration: Duration(milliseconds: 500),
            child: Text(
              "Connexion",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 10,
        ),
        FadeInDown(
          delay: Duration(milliseconds: 500),
          duration: Duration(milliseconds: 500),
          child: Text(
            "Abonnez vous d'abord pour accéder à cette fonctionnalité!",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, color: Colors.grey.shade500, height: 1.5),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width / 2.2,
          child: FadeInUp(
            duration: Duration(milliseconds: 1000),
            child: MaterialButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => LogInPage()));
              },
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Color(0xff44bd32).withOpacity(0.7),
              child: Row(
                children: [
                  Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Connexion",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildExpandedEventItem(
      {double topMargin,
      double leftMargin,
      double height,
      bool isVisible,
      double borderRadius}) {
    return Stack(
      children: [
        Positioned(
          top: widget.userStatus == false
              ? MediaQuery.of(context).size.height / 7
              : MediaQuery.of(context).size.height / 2.39,
          left: leftMargin,
          right: 0,
          // height: 85,
          child: AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: Color(0xFF162A49),
              ),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 37.5,
                  right: MediaQuery.of(context).size.width / 37.5,
                  top: 0,
                  bottom: 0),
              child: widget.userStatus == false ? _buildHeader() : null,
            ),
          ),
        ),
        Positioned(
          top: widget.userStatus == false
              ? MediaQuery.of(context).size.height / 2.7
              : MediaQuery.of(context).size.height / 7,
          left: leftMargin,
          right: 0,
          // height: 85,
          child: AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: Duration(milliseconds: 200),
            child: widget.userStatus == false
                ? Container(
                    height: MediaQuery.of(context).size.height / 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 37.5,
                        right: MediaQuery.of(context).size.width / 37.5,
                        top: 0,
                        bottom: 0),
                    child: _buildContent())
                : Container(
                    height: _selectedFiles.length == 0
                        ? MediaQuery.of(context).size.height / 2.6
                        : MediaQuery.of(context).size.height / 2.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 37.5,
                        right: MediaQuery.of(context).size.width / 37.5,
                        top: 0,
                        bottom: 0),
                    child: _buildUploadSection(),
                  ),
          ),
        ),
      ],
    );
  }

  void _toggle() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    _controller.fling(velocity: isOpen ? -2 : 2);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    else
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }
}
