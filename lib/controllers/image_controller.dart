import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf_compressor/pdf_compressor.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageController extends GetxController {
  RxList<XFile> images = <XFile>[].obs;
  RxBool isLoading = false.obs;

  void deleteImage(int index) {
    images.removeAt(index);
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final XFile image = images.removeAt(oldIndex);
    images.insert(newIndex, image);
  }

  Future<void> pickImages() async {
    isLoading.value = true;
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      images.insertAll(0, pickedImages);
    }
    isLoading.value = false;
  }

  Future<void> captureImage() async {
    isLoading.value = true;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      images.insert(0, image);
    }
    isLoading.value = false;
  }

  Future<void> createPdf(BuildContext context) async {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture images first.')),
      );
      return;
    }

    isLoading.value = true;

    final pdf = pw.Document(
      compress: true,
    );

    List<File> temp = await _compressImages(images
        .map(
          (e) => File(e.path),
        )
        .toList());
    for (var imageFile in temp) {
      final imageBytes = await File(imageFile.path).readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      // Compress the image if it's too large
      if (imageBytes.length > 1024 * 512) {
        // If image is larger than 500KB
        originalImage = img.copyResize(originalImage!, width: 800);
      }

      final image = pw.MemoryImage(
          Uint8List.fromList(img.encodeJpg(originalImage!)),
          dpi: 100);

      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
        pageFormat: PdfPageFormat.a4,
      ));
    }

    final String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    final List<int> bytes = await pdf.save();
    saveToDownloads(context: context, bytes: bytes, fileName: fileName);
  }

  static Future<bool> get checkStoragePermission async {
    if (Platform.isIOS) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final status = androidInfo.version.sdkInt >= 33
          ? await Permission.manageExternalStorage.request()
          : await Permission.storage.status;
      // final status = await Permission.storage.status;

      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    }

    return false;
  }

  Future<bool> isAndroidVersionBelow13() async {
    AndroidDeviceInfo androidDeviceInfo = await DeviceInfoPlugin().androidInfo;

    return (double.tryParse(androidDeviceInfo.version.release) ?? 13.0) < 13;
  }

  Future<Directory?> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      if (await isAndroidVersionBelow13()) {
        return Directory('/storage/emulated/0/Download');
      } else {
        Directory d = Directory('/storage/emulated/0/Download/image-to-pdf');
        if (await d.exists()) {
          return d;
        } else {
          await d.create(recursive: true);
          return d;
        }
      }
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  static Future<List<File>> _compressImages(List<File> images) async {
    final List<File> compressedImages = [];
    double total = 0.0;

    for (var image in images) {
      Uint8List? result = await compress(image);

      if (result != null) {
        final tempDir = await getTemporaryDirectory();
        final compressedFile =
            File('${tempDir.path}/compressed_${image.path.split('/').last}');
        await compressedFile.writeAsBytes(result);
        compressedImages.add(compressedFile);
        int byte = await compressedFile.length();
        double kb = byte / 1024;
        print("KB $kb");
        total += kb;
        // while (kb > ((25 * 1000) / images.length)) {
        //   Uint8List? result1 = await compress(compressedFile);
        //   if (result1 != null) {
        //     await compressedFile.writeAsBytes(result1);
        //     compressedImages.add(compressedFile);
        //     byte = await compressedFile.length();
        //     kb = byte / 1024;
        //   }
        // }
      } else {
        compressedImages
            .add(image); // Fallback to original if compression fails
      }
    }
    print("Total ===> $total");
    return compressedImages;
  }

  static Future<Uint8List?> compress(File image) async {
    final result = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      minWidth: 1024,
      minHeight: 768,
      quality: 50,
      format: CompressFormat.jpeg,
    );
    return result;
  }

  Future<void> saveToDownloads({
    required BuildContext context,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      if (!await checkStoragePermission) {
        return;
      }
      String downloadsPath = (await getDownloadDirectory())?.path ?? "";
      final file = File('$downloadsPath/$fileName.pdf');
      await file.writeAsBytes(bytes);
      var byte = await file.length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      print("0 $mb");
      // compressPdf(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download Completed ${file.path}')),
      );
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download Failed")),
      );
    }
  }

  // static const platform = MethodChannel('com.example/pdf_compressor');

  // Future<String> compressPdf(String inputPath) async {
  //   try {
  //     final result = await platform.invokeMethod('compressPdf', {
  //       'inputPath': inputPath,
  //       'outputPath': inputPath,
  //     });
  //     return result;
  //   } catch (e) {
  //     return 'Error: $e';
  //   }
  // }
}
