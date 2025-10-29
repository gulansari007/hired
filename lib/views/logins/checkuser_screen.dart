import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hired/views/home_screen.dart';
import 'package:hired/views/logins/login_screen.dart';

class CheckUserScreen extends StatefulWidget {
  const CheckUserScreen({super.key});

  @override
  State<CheckUserScreen> createState() => _CheckUserScreenState();
}

class _CheckUserScreenState extends State<CheckUserScreen> {
  checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
