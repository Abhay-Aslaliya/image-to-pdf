import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_to_pdf/controllers/image_controller.dart';

import 'widgets/image_preview.dart';

class MyHomePage extends StatelessWidget {
  final ImageController imageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Converter'),
        backgroundColor: Colors.indigo,
        leading: Icon(Icons.picture_as_pdf),
      ),
      body: Center(
        child: Obx(() => imageController.isLoading.value
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => imageController.pickImages(),
                        icon: Icon(Icons.image),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => imageController.captureImage(),
                        icon: Icon(Icons.camera_alt),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => imageController.createPdf(context),
                        icon: Icon(Icons.picture_as_pdf),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ImagePreview(),
                ],
              )),
      ),
    );
  }
}
