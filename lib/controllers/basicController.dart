import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class BasicController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  RxString selectedGender = 'Male'.obs;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  final Rx<DateTime?> dob = Rx<DateTime?>(null);

  final mediaFile = Rxn<File>();
  final picker = ImagePicker();
  var savedFilePath = ''.obs;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Please select your date of birth';
    }
    return null;
  }

  String? validateGender(String? value) {
    if (value == null) {
      return 'Please select your gender';
    }
    return null;
  }

  //
  Future<void> pickImg() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      File tempImage = File(picked.path);
      mediaFile.value = tempImage;
      await saveImageLocally(tempImage);
    }
  }

  // Pick image from camera and save locally
  Future<void> openCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      File tempImage = File(image.path);
      mediaFile.value = tempImage;
      await saveImageLocally(tempImage);
    } else {
      print("No image selected.");
    }
  }

  // Save the image to app's local directory
  Future<void> saveImageLocally(File image) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = basename(
      image.path,
    ); // import 'package:path/path.dart';
    final File localImage = await image.copy('${appDir.path}/$fileName');

    savedFilePath.value = localImage.path;
    print("Saved image at: ${savedFilePath.value}");
  }
}
