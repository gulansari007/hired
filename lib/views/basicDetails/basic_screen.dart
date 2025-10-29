import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hired/constant.dart';
import 'package:hired/controllers/basicController.dart';
import 'package:hired/views/basicDetails/location_screen.dart';
import 'package:hive/hive.dart';

class BasicScreen extends StatefulWidget {
  const BasicScreen({super.key});

  @override
  State<BasicScreen> createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  final basicController = Get.put(BasicController());
  Box? obj;

  @override
  void initState() {
    obj = Hive.box('myBox');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _showPicker(context);
                          },
                          child:
                              basicController.mediaFile.value != null
                                  ? CircleAvatar(
                                    radius: 40,
                                    backgroundImage: FileImage(
                                      basicController.mediaFile.value!,
                                    ),
                                  )
                                  : const Icon(
                                    CupertinoIcons.camera,
                                    size: 40,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide your basic details',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Full Name Field
                      _buildIOSTextField(
                        controller: basicController.nameController,
                        hint: 'Full Name',
                        icon: CupertinoIcons.person,
                        validator: basicController.validateName,
                        keyboardType: TextInputType.name,
                        isFirst: true,
                      ),

                      _buildDivider(),

                      // Phone Field
                      _buildIOSTextField(
                        controller: basicController.phoneController,
                        hint: 'Phone Number',
                        icon: CupertinoIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),

                      _buildDivider(),

                      // Date of Birth
                      _buildIOSDateSelector(),

                      _buildDivider(),

                      // Gender Selector
                      _buildIOSGenderSelector(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Get.theme.primaryColor, Get.theme.primaryColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Get.theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (basicController.validateName(
                                basicController.nameController.text,
                              ) ==
                              null &&
                          basicController.validateDateOfBirth(
                                basicController.dob.value,
                              ) ==
                              null &&
                          basicController.validateGender(
                                basicController.selectedGender.value,
                              ) ==
                              null) {
                        Get.to(() => LocationScreen());
                      } else {
                        _showErrorDialog();
                      }
                      obj?.put(
                        'name',
                        basicController.nameController.text.toString(),
                      );
                      obj?.put(
                        'phone',
                        basicController.phoneController.text.toString(),
                      );
                      obj?.put('dob', basicController.dob.value);
                      obj?.put('gender', basicController.selectedGender.value);
                      obj?.put('profileImage', basicController.mediaFile.value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () async {
                  await basicController.openCamera();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  basicController.pickImg();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIOSTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: CupertinoColors.secondaryLabel.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: CupertinoColors.secondaryLabel),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 17, color: Colors.black),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 17, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSDateSelector() {
    return Obx(
      () => GestureDetector(
        onTap: () => _showDatePicker(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: CupertinoColors.secondaryLabel.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.calendar,
                  size: 18,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  basicController.dob.value != null
                      ? '${basicController.dob.value!.day}/${basicController.dob.value!.month}/${basicController.dob.value!.year}'
                      : 'Date of Birth',
                  style: TextStyle(
                    fontSize: 17,
                    color:
                        basicController.dob.value != null
                            ? Colors.black
                            : Colors.grey[400],
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIOSGenderSelector() {
    return Obx(
      () => GestureDetector(
        onTap: () => _showGenderPicker(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: CupertinoColors.secondaryLabel.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.person_2,
                  size: 18,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  basicController.selectedGender.value.isNotEmpty
                      ? basicController.selectedGender.value
                      : 'Gender',
                  style: TextStyle(
                    fontSize: 17,
                    color:
                        basicController.selectedGender.value.isNotEmpty
                            ? Colors.black
                            : Colors.grey[400],
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 62),
      height: 0.5,
      color: Colors.grey[300],
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        child: const Text('Done'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime:
                        basicController.dob.value ?? DateTime.now(),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (date) {
                      basicController.dob.value = date;
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showGenderPicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: const Text('Select Gender'),
            actions:
                basicController.genderOptions.map((gender) {
                  return CupertinoActionSheetAction(
                    onPressed: () {
                      basicController.selectedGender.value = gender;
                      Navigator.of(context).pop();
                    },
                    child: Text(gender),
                  );
                }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Basic details saved successfully'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill all fields correctly'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
