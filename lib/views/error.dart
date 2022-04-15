import 'package:flutter/material.dart';
import 'package:watermarking/views/home.dart';
import 'package:watermarking/views/login.dart';
import 'dart:io';

class ErrorPage extends StatefulWidget {
  final dynamic pageToGo;

  const ErrorPage({Key key, this.pageToGo = "/Home"}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  showSpinner(BuildContext context, dynamic content) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF162A49)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: Image.asset('assets/images/no-connection.gif'),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 7,
                vertical: MediaQuery.of(context).size.height / 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Ooops! 😓",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 54,
                ),
                Text(
                  "Vous n'êtes pas connecté à internet. Vérifiez votre connectivité et réessayez.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 51,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 13.5,
                ),
                MaterialButton(
                  onPressed: () async {
                    try {
                      final result =
                          await InternetAddress.lookup('www.google.com');
                      if (result.isNotEmpty &&
                          result[0].rawAddress.isNotEmpty) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => widget.pageToGo == "/Home"
                                    ? HomePage()
                                    : widget.pageToGo == "/logIn"
                                        ? LogInPage()
                                        : HomePage()));
                      }
                    } on SocketException catch (_) {}
                  },
                  height: MediaQuery.of(context).size.height / 18,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 7.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.orange.shade400,
                  child: Text(
                    "Try Again",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
