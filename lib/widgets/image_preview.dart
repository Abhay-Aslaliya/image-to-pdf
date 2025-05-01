import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_to_pdf/controllers/image_controller.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ImagePreview extends StatelessWidget {
  ImagePreview({Key? key}) : super(key: key);

  final ImageController imageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => imageController.images.isNotEmpty
        ? Expanded(
            child: true
                ? true
                    ? GridView.builder(
                        itemCount: imageController.images.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Number of columns
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1, // Width to height ratio
                        ),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Image.file(
                                File(imageController.images[index].path),
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: 200,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.green,
                                      ),
                                      onTap: () {},
                                    ),
                                    GestureDetector(
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Confirm Delete"),
                                              content: const Text(
                                                  "Are you sure you want to delete this image?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("Delete"),
                                                  onPressed: () {
                                                    imageController
                                                        .deleteImage(index);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            key: Key(imageController.images[index].path),
                          );
                        },
                      )
                    : ListView.separated(
                        itemCount: imageController.images.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                        itemBuilder: (context, index) => Stack(
                          children: [
                            Image.file(
                              File(imageController.images[index].path),
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: 200,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: const Text(
                                            "Are you sure you want to delete this image?"),
                                        actions: [
                                          TextButton(
                                            child: const Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text("Delete"),
                                            onPressed: () {
                                              imageController
                                                  .deleteImage(index);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                          key: Key(imageController.images[index].path),
                        ),
                      )
                : ReorderableGridView.count(
                    crossAxisCount: 3,
                    children:
                        List.generate(imageController.images.length, (index) {
                      return Stack(
                        children: [
                          Image.file(
                            File(imageController.images[index].path),
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                          "Are you sure you want to delete this image?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Delete"),
                                          onPressed: () {
                                            imageController.deleteImage(index);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        key: Key(imageController.images[index].path),
                      );
                    }),
                    onReorder: (int oldIndex, int newIndex) {
                      imageController.reorderImages(oldIndex, newIndex);
                    },
                  ),
          )
        : const Expanded(child: const Text('No images selected')));
  }
}
