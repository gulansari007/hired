import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:hired/controllers/phoneController.dart';
import 'package:hired/views/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String veriId;
  OtpScreen({super.key, required this.veriId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final phoneController = Get.put(PhoneController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("OTP sent to +91 ${phoneController.phoneController.value}"),
            SizedBox(height: 20),
            TextField(
              controller: phoneController.otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Verify OTP
                if (phoneController.otpController.text.isEmpty) {
                  Get.snackbar(
                    "Error",
                    "Please enter the OTP",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                          verificationId: widget.veriId,
                          smsCode:
                              phoneController.otpController.text.toString(),
                        );
                    FirebaseAuth.instance.signInWithCredential(credential).then(
                      (value) {
                        if (value.user != null) {
                          Get.snackbar(
                            "Success",
                            "OTP verified successfully",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          Get.off(HomeScreen());
                        } else {
                          Get.snackbar(
                            "Error",
                            "Invalid OTP",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    );
                  } catch (e) {
                    Get.snackbar(
                      "Error",
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }
              },
              child: Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
