import 'package:flutter/material.dart';

import 'camera_view_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Face Detection",
      checkerboardRasterCacheImages: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.lightBlue),
        buttonTheme: ButtonThemeData(buttonColor: Colors.lightBlue),
      ),
      home: const CameraViewScreen(title: 'Face Detection POC'),
    );
  }
}
