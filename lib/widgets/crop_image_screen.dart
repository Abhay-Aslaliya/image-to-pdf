import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:get/get.dart';
import 'package:image_to_pdf/controllers/image_controller.dart';
import 'package:path_provider/path_provider.dart';

class CropImageScreen extends StatefulWidget {
  final String imagePath;
  final int index;

  CropImageScreen({required this.imagePath, required this.index});

  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final _cropController = CropController();
  final ImageController imageController = Get.find();
  File? _croppedFile;
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    File imageFile = File(widget.imagePath);
    _imageData = await imageFile.readAsBytes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.crop),
            onPressed: () {
              _cropController.crop();
            },
          ),
        ],
      ),
      body: _imageData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Expanded(
                    child: Crop(
                      controller: _cropController,
                      image: _imageData!,
                      onCropped: (image) async {
                        final directory = await getTemporaryDirectory();
                        final filePath =
                            '${directory.path}/${DateTime.now().microsecondsSinceEpoch.toString()}.jpg';

                        final file = File(filePath);
                        await file.writeAsBytes(image);
                        imageController.updateImage(widget.index, file.path);
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
