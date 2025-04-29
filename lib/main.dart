import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_to_pdf/controllers/image_controller.dart';
import 'package:image_to_pdf/home_screen.dart';

void main() {
  Get.put(ImageController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PDF Converter',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        hintColor: Colors.indigoAccent,
      ),
      home: MyHomePage(),
    );
  }
}
