import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hired/views/logins/otp_screen.dart';

class PhoneController extends GetxController {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  sendOtp() async {
    if (phoneController.text.isEmpty && phoneController.text.length < 10) {
      Get.snackbar(
        "Error",
        "Please enter your phone number",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91${phoneController.text.toString()}",
        timeout: Duration(seconds: 15),

        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Get.snackbar(
            "Success",
            "OTP sent successfully",
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            "Error",
            e.message.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.snackbar(
            "Success",
            "OTP sent successfully",
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.to(OtpScreen(veriId: verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      Get.snackbar(
        "Success",
        "OTP sent successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  verifyOtp() async {}
}
