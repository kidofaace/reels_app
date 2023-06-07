import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reel_app/main_menu.dart';
import 'package:reel_app/otp.dart';
import 'package:reel_app/uploading_reels.dart';
import 'package:reel_app/viewreels.dart';
import 'firebase_options.dart';
import 'package:reel_app/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: 'Reels app',
    initialRoute: '_login',
    debugShowCheckedModeBanner: false,
    routes: {
      '_login': (context) => login(),
      'otp': (context) => otp(),
      'mainmenu': (context) => mainmenu(),
      'upload': (context) => VideoUploadScreen(),
      'watch': (context) =>ReelsPage()
    },
  ));
}
