import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetController extends GetxController {
  TextEditingController emailController = TextEditingController();
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email address",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      UserCredential? userCredential;
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        Get.snackbar(
          "Success",
          "Password reset email sent successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      try {} on FirebaseAuthException catch (e) {
        Get.snackbar(
          "Error",
          e.message.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
