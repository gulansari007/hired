import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/views/basicDetails/basic_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SignupController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isNextButtonEnabled = false.obs;
  RxBool isLogin = true.obs;
  RxBool isLoading = false.obs;

  // signUp(String email, String password) async {
  //   if (email.isEmpty || password.isEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       'Please fill all fields',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } else {
  //     UserCredential? userCredential;
  //     try {
  //       userCredential = await FirebaseAuth.instance
  //           .createUserWithEmailAndPassword(email: email, password: password)
  //           .then((Value) => Get.to(() => LoginScreen()));
  //     } on FirebaseAuthException catch (e) {
  //       return Get.snackbar(
  //         'Error',
  //         e.message.toString(),
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //     }
  //   }
  // }
  Future<void> signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    isLoading.value = true;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogin', true);
      isLogin.value = true;

      // ✅ This is a new user, go to BasicScreen
      Get.offAll(() => BasicScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration Failed', e.message ?? 'Unknown error');
    } finally {
      isLoading.value = false;
    }
  }
}
