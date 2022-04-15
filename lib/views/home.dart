import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:watermarking/components/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future getImages(context) async {
  final response = await http.get("http://127.0.0.1:8000/api/image/");
  Map<String, dynamic> data = jsonDecode(response.body);
  List<String> _images = [];

  for (var item in data["results"]) {
    _images.add(item["image"]);
  }
  return _images;
}

Future applyWatermark(context, id) async {
  var data = {'id_image': id};
  final response =
      await http.post("http://127.0.0.1:8000/api/watermark/", body: data);
  return jsonDecode(response.body);
}

class HomePage extends StatefulWidget {
  final bool openBottomNavBar;
  const HomePage({
    Key key,
    this.openBottomNavBar = false,
  }) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  List<String> _images = [];
  bool _userStatus;

  @override
  initState() {
    super.initState();

    _loadImages();
  }

  _loadImages() {
    return this._memoizer.runOnce(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      _images = await getImages(context);
      bool status = (prefs.getBool("isLoggedIn") ?? false);

      setState(() {
        _images = _images;
        _userStatus = status;
      });
    });
  }

  void _saveNetworkImage(path) async {
    GallerySaver.saveImage(path).then((bool success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Sauvegarde réussie.',
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

  Widget _homeContent() {
    return Stack(children: [
      SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: NetworkImage(
                            "http://127.0.0.1:8000/media/images/1.jpg"),
                        fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient:
                          LinearGradient(begin: Alignment.bottomRight, colors: [
                        Colors.black.withOpacity(.4),
                        Colors.black.withOpacity(.2),
                      ])),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Lifestyle Sale",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: Center(
                            child: Text(
                          "Image Gallery",
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                  child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: _images
                    .map((item) => Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                    image: NetworkImage(item),
                                    fit: BoxFit.cover)),
                            child: Transform.translate(
                              offset: Offset(50, -50),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 65, vertical: 63),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white),
                                child: InkWell(
                                    child: Icon(
                                      Icons.download_sharp,
                                      size: 16,
                                    ),
                                    onTap: () async {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                'Sauvegarde de l\'image...',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Color(0xFF162A49),
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              duration: Duration(seconds: 1),
                                              backgroundColor: Colors.white));

                                      var urlList = item.split('/');
                                      var idImg = urlList[urlList.length - 1]
                                          .split(".")[0];
                                      applyWatermark(context, idImg)
                                          .then((value) {
                                        _saveNetworkImage(value["image"]);
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ))
            ],
          ),
        ),
      ),
      BottomNav(
        openBottomNavBar: widget.openBottomNavBar,
        userStatus: this._userStatus,
      )
    ]);
  }

  Widget _buildHomeContent() {
    if (_images == null || _images.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height / 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Text("No data at the moment...",
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height / 40))),
              ],
            )
          ],
        ),
      );
    } else {
      return FutureBuilder<dynamic>(
          future: _loadImages(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  height: MediaQuery.of(context).size.height / 5,
                  child: Center(
                    child: Text(
                      "Loading data...",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 50.75,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ));
            } else {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return _homeContent();
              }
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: _buildHomeContent()));
  }
}
