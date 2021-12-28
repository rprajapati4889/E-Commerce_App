import 'dart:io';

import '../../../data/models/product_model.dart';
import 'cubit/product_cubit.dart';
import '../../../utils/constants.dart';
import '../../../utils/default_button.dart';
import '../../../utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String dropdownValue = 'others';
  List<String> images = [];

  bool get isPopulated =>
      productNameController.text.trim().isNotEmpty &&
      descriptionController.text.trim().isNotEmpty &&
      quantityController.text.trim().isNotEmpty &&
      priceController.text.trim().isNotEmpty &&
      images.isNotEmpty &&
      dropdownValue.trim().isNotEmpty;

  bool get isPopulatedForImageUpload =>
      imageFileList!.isNotEmpty &&
      productNameController.text.trim().isNotEmpty &&
      descriptionController.text.trim().isNotEmpty &&
      quantityController.text.trim().isNotEmpty &&
      priceController.text.trim().isNotEmpty &&
      dropdownValue.trim().isNotEmpty;

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    setState(() {});
  }

  Future<void> onSubmitProduct() async {
    if (isPopulatedForImageUpload) {
      images = await BlocProvider.of<ProductCubit>(context)
          .uploadImages(images: imageFileList!);
    }

    User user = await BlocProvider.of<ProductCubit>(context).getSeller();

    if (isPopulated) {
      var productId = UniqueKey().toString() +
          DateTime.now().millisecondsSinceEpoch.toString();
      // Create new product
      var newProduct = ProductModel(
        pid: productId,
        name: productNameController.text.trim(),
        description: descriptionController.text.trim(),
        category: dropdownValue.trim(),
        images: images,
        rating: '0',
        quantity: quantityController.text.trim(),
        price: priceController.text.trim(),
        isAvailable:
            int.parse(quantityController.text.trim()) > 0 ? true : false,
        sellerId: user.uid,
      );

      BlocProvider.of<ProductCubit>(context).addProduct(newProduct: newProduct);

      Navigator.pop(context);
    } else {
      UtilDialog.showInformation(
        context,
        content: "Either some fileds are empty or somthing went wrong",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Product"),
          backgroundColor: kPrimaryColor,
          centerTitle: true,
        ),
        body: BlocListener<ProductCubit, ProductState>(
          listener: (context, state) {
            if (state is ImagesUploading) {
              UtilDialog.showWaiting(context);
            }

            if (state is ImagesUploadError) {
              UtilDialog.hideWaiting(context);
              UtilDialog.showInformation(context, content: state.message);
            }

            if (state is ProductUploaded) {
              UtilDialog.hideWaiting(context);
            }

            if (state is ProductError) {
              UtilDialog.hideWaiting(context);
              UtilDialog.showInformation(context, content: state.message);
            }
          },
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _buildInput(),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _buildInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            // category input
            DropdownButtonFormField<String>(
              value: dropdownValue,
              icon: const Icon(Icons.category_outlined),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              decoration: InputDecoration(
                labelText: "Category",
              ),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: <String>[
                'electronics',
                'fashion',
                'grocery',
                'home & kitchen',
                'medicines',
                'veg & fruits',
                'others'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            SizedBox(height: 20),
            // Product name input
            TextFormField(
              controller: productNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Product Name",
              ),
            ),

            SizedBox(height: 20),
            // Description input
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Description",
              ),
            ),

            SizedBox(height: 20),
            // Quantity input
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.text,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Quantity",
              ),
            ),

            SizedBox(height: 20),
            // Price input
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.text,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Price",
              ),
            ),

            SizedBox(height: 20),
            // Images input
            ElevatedButton.icon(
              onPressed: () {
                selectImages();
              },
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text("Add Images"),
            ),

            SizedBox(height: 20),

            imageFileList!.length > 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: imageFileList!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Image.file(
                          File(imageFileList![index].path),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  )
                : Container(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: DefaultButton(
        text: "Confirm",
        press: onSubmitProduct,
      ),
    );
  }
}