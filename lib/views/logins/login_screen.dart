import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/loginController.dart';
import 'package:hired/controllers/signupController.dart';
import 'package:hired/views/basicDetails/basic_screen.dart';
import 'package:hired/views/logins/forget_screen.dart';
import 'package:hired/views/logins/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // App Icon/Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Get.theme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Welcome Text
                  Text(
                    'Welcome Back!'.tr,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.label,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue your journey'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Input Fields Container
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.secondarySystemGroupedBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email Field
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.separator,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: loginController.emailController,
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.label,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email'.tr,
                              labelStyle: const TextStyle(
                                color: CupertinoColors.secondaryLabel,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              hintText: 'Enter your email'.tr,
                              hintStyle: const TextStyle(
                                color: CupertinoColors.placeholderText,
                              ),
                              prefixIcon: const Icon(
                                CupertinoIcons.mail,
                                color: CupertinoColors.secondaryLabel,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email'.tr;
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Please enter a valid email address'.tr;
                              }
                              return null;
                            },
                          ),
                        ),

                        // Password Field
                        TextFormField(
                          controller: loginController.passwordController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password'.tr,
                            labelStyle: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            hintText: 'Enter your password'.tr,
                            hintStyle: const TextStyle(
                              color: CupertinoColors.placeholderText,
                            ),
                            prefixIcon: const Icon(
                              CupertinoIcons.lock,
                              color: CupertinoColors.secondaryLabel,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password'.tr;
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters'
                                  .tr;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        Get.to(() => const ForgetScreen());
                      },
                      child: Text(
                        'Forgot Password?'.tr,
                        style: TextStyle(
                          color: Get.theme.primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  Obx(() {
                    return loginController.isLoading.value
                        ? Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CupertinoActivityIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                        : Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,

                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Get.theme.primaryColor.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(16),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginController.loginEmail(
                                  loginController.emailController.text,
                                  loginController.passwordController.text,
                                );
                              }
                            },
                            child: Text(
                              'Sign In'.tr,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        );
                  }),

                  const SizedBox(height: 22),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: CupertinoColors.separator,
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or'.tr,
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: CupertinoColors.separator,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Sign Up Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.secondarySystemGroupedBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CupertinoColors.separator,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?'.tr,
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: () {
                            Get.to(() => const SignupScreen());
                          },
                          child: Text(
                            'Sign Up'.tr,
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      User? user = await loginController.signInWithGoogle();
                      if (user != null) {
                        print("Logged in: ${user.email}");
                      }
                    },
                    child: Text('Sign in with Google'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
