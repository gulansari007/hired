import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hired/controllers/locationController.dart';
import 'package:hired/views/ads/ads_screen.dart';
import 'package:hired/views/home_screen.dart';
import 'package:hired/views/screens/bottombar_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Get.back(),
          child: Icon(CupertinoIcons.back, size: 28),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: CupertinoColors.label,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Current Location Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(
                () =>
                    locationController.isLoadingLocation.value
                        ? Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                CupertinoColors
                                    .secondarySystemGroupedBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CupertinoActivityIndicator(
                              color: Get.theme.primaryColor,
                            ),
                          ),
                        )
                        : Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Get.theme.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              locationController.getCurrentLocation();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.location_fill,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Use Current Location',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 24),

            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoTextField(
                  controller: locationController.locationController,
                  placeholder: 'Search for a city',
                  placeholderStyle: const TextStyle(
                    color: CupertinoColors.placeholderText,
                    fontSize: 16,
                  ),
                  style: const TextStyle(
                    color: CupertinoColors.label,
                    fontSize: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemGroupedBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      CupertinoIcons.search,
                      color: CupertinoColors.placeholderText,
                      size: 20,
                    ),
                  ),
                  onChanged: (value) {
                    locationController.searchQuery.value = value;
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cities List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(
                  () => ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: locationController.filteredCities.length,
                    separatorBuilder:
                        (context, index) => Container(
                          height: 0.5,
                          margin: const EdgeInsets.only(left: 20),
                          color: CupertinoColors.separator,
                        ),
                    itemBuilder: (context, index) {
                      final city = locationController.filteredCities[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              index == 0
                                  ? const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  )
                                  : index ==
                                      locationController.filteredCities.length -
                                          1
                                  ? const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  )
                                  : BorderRadius.zero,
                        ),
                        child: CupertinoListTile(
                          title: Text(
                            city,
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: const Icon(
                            CupertinoIcons.chevron_right,
                            color: CupertinoColors.tertiaryLabel,
                            size: 16,
                          ),
                          onTap: () => locationController.selectCity(city),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(
                () => Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        locationController.isNextButtonEnabled.value
                            ? Get.theme.primaryColor
                            : Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow:
                        locationController.isNextButtonEnabled.value
                            ? [
                              BoxShadow(
                                color: Get.theme.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed:
                        locationController.isNextButtonEnabled.value
                            ? () => Get.offAll(
                              BottombarScreen(),
                            ) // Add your next screen here
                            : null,
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            locationController.isNextButtonEnabled.value
                                ? CupertinoColors.white
                                : CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
