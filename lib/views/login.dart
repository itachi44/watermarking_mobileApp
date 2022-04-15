import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:watermarking/components/dialog.dart';
import 'package:watermarking/views/home.dart';
import 'package:watermarking/views/error.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;

Future logIn(data) async {
  final response =
      await http.post("http://127.0.0.1:8000/api/login/", body: data);
  return response.statusCode;
}

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  int activeIndex = 0;
  TextEditingController identifierController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  connectUser(userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logIn(userData).then((value) {
      if (value == 200) {
        prefs.setBool("isLoggedIn", true);
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => HomePage(
                  openBottomNavBar: true,
                )));
      } else {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "Input error",
                description: "The username or password is incorrect.",
                btnText: "Close",
              );
            });
      }
    });
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (this.mounted) {
        setState(() {
          activeIndex++;

          if (activeIndex == 4) activeIndex = 0;
        });
      }
    });
    super.initState();
  }

  showSpinner(BuildContext context, content) {
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(0),
      insetPadding: EdgeInsets.zero,
      content: Container(
        height: MediaQuery.of(context).size.height / 16,
        width: MediaQuery.of(context).size.width / 50,
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 6,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient:
                        LinearGradient(begin: Alignment.bottomRight, colors: [
                      Colors.white.withOpacity(.4),
                      Colors.white.withOpacity(.2),
                    ])),
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: const [Colors.white],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height / 179.2),
                  child: Text(content))
            ],
          ),
        ),
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

  Widget _buildLogIn() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 41),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 41,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                child: Stack(children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: activeIndex == 0 ? 1 : 0,
                      duration: Duration(
                        seconds: 1,
                      ),
                      curve: Curves.linear,
                      child: Image.asset('assets/images/login4.png',
                          height: MediaQuery.of(context).size.height / 2),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: activeIndex == 1 ? 1 : 0,
                      duration: Duration(seconds: 1),
                      curve: Curves.linear,
                      child: Image.asset('assets/images/login1.png',
                          height: MediaQuery.of(context).size.height / 2),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: activeIndex == 2 ? 1 : 0,
                      duration: Duration(seconds: 1),
                      curve: Curves.linear,
                      child: Image.asset('assets/images/login2.png',
                          height: MediaQuery.of(context).size.height / 2),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                        opacity: activeIndex == 3 ? 1 : 0,
                        duration: Duration(seconds: 1),
                        curve: Curves.linear,
                        child: Image.asset('assets/images/login3.png',
                            height: MediaQuery.of(context).size.height / 2)),
                  )
                ]),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              TextFormField(
                controller: identifierController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0.0),
                  labelText: 'Identifiant',
                  hintText: 'Nom d\'utilisateur ou e-mail',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 58,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: MediaQuery.of(context).size.height / 58,
                  ),
                  prefixIcon: Icon(
                    Iconsax.user,
                    color: Colors.black,
                    size: MediaQuery.of(context).size.height / 45,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 41,
              ),
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0.0),
                  labelText: 'Mot de passe',
                  hintText: 'Mot de passe',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: MediaQuery.of(context).size.height / 58,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 58,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Iconsax.key,
                    color: Colors.black,
                    size: MediaQuery.of(context).size.height / 45,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height / 58,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 27,
              ),
              MaterialButton(
                onPressed: () async {
                  try {
                    final result = await InternetAddress.lookup('google.com');
                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                      if (_formKey.currentState.validate()) {
                        var identifier = identifierController.text;
                        var password = passwordController.text;
                        var userData = {
                          "identifiant": identifier,
                          "mot_de_passe": password
                        };
                        showSpinner(context, "connexion en cours...");
                        connectUser(userData);
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogBox(
                                title: "Erreur de saisie",
                                description:
                                    "Les données entrées dont incorrectes.",
                                btnText: "Fermer",
                              );
                            });
                      }
                    }
                  } on SocketException catch (_) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ErrorPage(pageToGo: "/logIn")),
                        (Route<dynamic> route) => false);
                  }
                },
                height: MediaQuery.of(context).size.height / 18,
                color: Color(0xFF162A49),
                child: Text(
                  "Se connecter",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.height / 51),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 81,
                    horizontal: MediaQuery.of(context).size.width / 7.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 27,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous n\'avez pas de compte?',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: MediaQuery.of(context).size.height / 58,
                        fontWeight: FontWeight.w400),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'S\'abonner',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: MediaQuery.of(context).size.height / 58,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Connexion",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height / 51,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFF162A49),
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Center(
              child: _buildLogIn(),
            )));
  }
}
