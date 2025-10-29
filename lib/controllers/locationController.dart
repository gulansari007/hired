import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationController extends GetxController {
  final locationController = TextEditingController();
  final List<String> _allCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Ahmedabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Jaipur',
    'Surat',
    'Lucknow',
    'Kanpur',
    'Nagpur',
    'Indore',
    'Thane',
    'Bhopal',
    'Visakhapatnam',
    'Pimpri-Chinchwad',
    'Patna',
    'Vadodara',
    'Ghaziabad',
    'Ludhiana',
    'Agra',
    'Nashik',
    'Faridabad',
    'Meerut',
    'Rajkot',
    'Varanasi',
    'Srinagar',
    'Amritsar',
  ];

  final RxList<String> filteredCities = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxString selectedCity = ''.obs;
  final RxBool isNextButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    filteredCities.addAll(_allCities);

    // Listen to search query changes
    ever(searchQuery, (_) => _filterCities());

    // Listen to text field changes and enable/disable button
    locationController.addListener(() {
      selectedCity.value = locationController.text;
      _updateNextButtonState();
    });

    // Reactively update button state when selectedCity changes
    ever(selectedCity, (_) => _onCityChanged());

    // Load saved location on initialization
    _loadSavedLocation();
  }

  void _filterCities() {
    if (searchQuery.value.isEmpty) {
      filteredCities.value = _allCities;
    } else {
      filteredCities.value =
          _allCities
              .where(
                (city) => city.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  void _updateNextButtonState() {
    isNextButtonEnabled.value = selectedCity.value.isNotEmpty;
  }

  Future<void> _onCityChanged() async {
    _updateNextButtonState();
    await _saveLocation(selectedCity.value);
  }

  Future<void> getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String locationText =
              '${place.locality}, ${place.administrativeArea}, ${place.country}';

          locationController.text = locationText;
          selectedCity.value = locationText;
        }
      } else {
        Get.snackbar(
          'Location Access Denied',
          'Please enable location permissions in app settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade500,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Location Error',
        'Unable to retrieve location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void selectCity(String city) {
    locationController.text = city;
    selectedCity.value = city;
    _updateNextButtonState(); // Ensure button updates immediately
  }

  Future<void> _saveLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', location);
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('selected_city');
    if (savedCity != null && savedCity.isNotEmpty) {
      locationController.text = savedCity;
      selectedCity.value = savedCity;
    }
  }
}
