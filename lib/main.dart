import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:watermarking/views/home.dart';

Future<void> main() async {
  //assurons nous que la liaison entre les widgets et le moteur flutter est faites
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}
