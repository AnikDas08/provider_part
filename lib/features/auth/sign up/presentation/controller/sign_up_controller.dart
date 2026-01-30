import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/countries.dart';
import 'package:haircutmen_user_app/utils/helpers/other_helper.dart';

import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../utils/app_utils.dart';

class LocationModel {
  final String placeId;
  final String displayName;
  final String lat;
  final String lon;

  // Address fields (OSM)
  final String houseNumber;
  final String road;
  final String neighbourhood;
  final String suburb;
  final String city;
  final String town;
  final String village;
  final String county;
  final String state;
  final String postcode;
  final String country;
  final String countryCode;

  // Computed fields
  final String shortName;
  final String searchableName;
  final String fullAddress;

  LocationModel({
    required this.placeId,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.houseNumber,
    required this.road,
    required this.neighbourhood,
    required this.suburb,
    required this.city,
    required this.town,
    required this.village,
    required this.county,
    required this.state,
    required this.postcode,
    required this.country,
    required this.countryCode,
    required this.shortName,
    required this.searchableName,
    required this.fullAddress,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};

    String getValue(String key) => address[key]?.toString() ?? '';

    /// -------- Short Name (Most specific) --------
    String shortName = getValue('neighbourhood').isNotEmpty
        ? getValue('neighbourhood')
        : getValue('suburb').isNotEmpty
        ? getValue('suburb')
        : getValue('road').isNotEmpty
        ? getValue('road')
        : getValue('city').isNotEmpty
        ? getValue('city')
        : getValue('town').isNotEmpty
        ? getValue('town')
        : getValue('village').isNotEmpty
        ? getValue('village')
        : getValue('state');

    /// -------- Searchable Name --------
    List<String> searchParts = [];
    if (getValue('neighbourhood').isNotEmpty) {
      searchParts.add(getValue('neighbourhood'));
    }
    if (getValue('road').isNotEmpty) {
      searchParts.add(getValue('road'));
    }
    if (getValue('city').isNotEmpty) {
      searchParts.add(getValue('city'));
    } else if (getValue('town').isNotEmpty) {
      searchParts.add(getValue('town'));
    }

    String searchableName = searchParts.isNotEmpty
        ? searchParts.join(', ')
        : json['display_name'] ?? '';

    /// -------- Full Address (Manual structured) --------
    List<String> fullParts = [
      getValue('house_number'),
      getValue('road'),
      getValue('neighbourhood'),
      getValue('suburb'),
      getValue('city'),
      getValue('town'),
      getValue('village'),
      getValue('county'),
      getValue('state'),
      getValue('postcode'),
      getValue('country'),
    ].where((e) => e.isNotEmpty).toList();

    String fullAddress = fullParts.join(', ');

    return LocationModel(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] ?? '',
      lat: json['lat'] ?? '',
      lon: json['lon'] ?? '',
      houseNumber: getValue('house_number'),
      road: getValue('road'),
      neighbourhood: getValue('neighbourhood'),
      suburb: getValue('suburb'),
      city: getValue('city'),
      town: getValue('town'),
      village: getValue('village'),
      county: getValue('county'),
      state: getValue('state'),
      postcode: getValue('postcode'),
      country: getValue('country'),
      countryCode: getValue('country_code'),
      shortName: shortName,
      searchableName: searchableName,
      fullAddress: fullAddress,
    );
  }
}

class SignUpController extends GetxController {
  final signUpFormKey = GlobalKey<FormState>();

  bool isPopUpOpen = false;
  bool isLoading = false;
  bool isLoadingVerify = false;
  bool isLoadingWork = false;
  String completePhoneNumber = '';
  String countryCode = '+880';
  String countryFlag = '🇧🇩';

  List<LocationModel> locationSuggestions = [];
  bool isLocationLoading = false;
  String? latitude;
  String? longitude;
  Timer? _debounce;

  List selectedOption = ["User", "Consultant"];
  String? image;
  String signUpToken = '';

  static SignUpController get instance => Get.put(SignUpController());

  TextEditingController nameController = TextEditingController(text: kDebugMode ? "Namimul Hassan" : "");
  TextEditingController emailController = TextEditingController(text: kDebugMode ? "developernaimul00@gmail.com" : '');
  TextEditingController passwordController = TextEditingController(text: kDebugMode ? 'hello123' : '');
  TextEditingController confirmPasswordController = TextEditingController(text: kDebugMode ? 'hello123' : '');
  TextEditingController phoneNumberController = TextEditingController(text: kDebugMode ? '1865965581' : '');
  TextEditingController otpController = TextEditingController(text: kDebugMode ? '123456' : '');
  TextEditingController locationController = TextEditingController(text: kDebugMode ? 'Dhaka' : '');
  TextEditingController referralController = TextEditingController(text: kDebugMode ? '23456' : '');

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void onLocationChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchLocation(value);
    });
  }

  onCountryChange(Country value) {
    countryCode = value.dialCode.toString();
    update();
  }

  openGallery() async {
    image = await OtherHelper.openGallery();
    update();
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      locationSuggestions.clear();
      update();
      return;
    }

    isLocationLoading = true;
    update();

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5');

    final response = await http.get(url, headers: {"User-Agent": "HaircutMenApp"});

    if (response.statusCode == 200) {
      debugPrint("RAW LOCATION RESPONSE 👉 ${response.body}");
      final List data = jsonDecode(response.body);
      debugPrint("PARSED LIST LENGTH 👉 ${data.length}");
      locationSuggestions = data.map((e) => LocationModel.fromJson(e)).toList();
    } else {
      locationSuggestions.clear();
    }

    isLocationLoading = false;
    update();
  }

  void selectLocation(LocationModel location) {
    locationController.text = location.displayName;
    latitude = location.lat;
    longitude = location.lon;
    locationSuggestions.clear();
    update();
  }

  signUpUser() async {
    if (!signUpFormKey.currentState!.validate()) return;
    isLoading = true;
    update();
    Map<String, dynamic> body = {
      "role": "PROVIDER",
      "name": nameController.text,
      "email": emailController.text,
      "contact": phoneNumberController.text,
      "countryCode": countryCode,
      "location": locationController.text,
      "latitude": latitude ?? "",
      "longitude": longitude ?? "",
      "password": passwordController.text,
      "coordinates": [double.tryParse(latitude ?? '0.0'), double.tryParse(longitude ?? '0.0')],
      "referralCode": referralController.text,
    };

    var response = await ApiService.post(ApiEndPoint.signUp, body: body);

    if (response.statusCode == 200) {
      Get.toNamed(AppRoutes.verifyUser);
    } else if (response.statusCode == 409) {
      Get.offAllNamed(AppRoutes.signIn);
      Get.snackbar(response.statusCode.toString(), AppString.user_exits);
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoading = false;
    update();
  }

  Future<void> verifyOtpRepo() async {
    isLoadingVerify = true;
    update();
    Map<String, String> body = {
      "email": emailController.text,
      "oneTimeCode": otpController.text
    };
    Map<String, String> header = {"SignUpToken": "signUpToken $signUpToken"};
    var response = await ApiService.post(
      ApiEndPoint.verifyUser,
      body: body,
      header: header,
    );

    if (response.statusCode == 200) {
      Utils.successSnackBar(AppString.successful, response.message);
      Get.offAllNamed(AppRoutes.signIn);
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoadingVerify = false;
    update();
  }

  resetOpt() async {
    isLoadingWork = true;
    update();
    Map<String, String> body = {"email": emailController.text};
    var response = await ApiService.post(ApiEndPoint.reset_otp, body: body);

    if (response.statusCode == 200) {
      Get.toNamed(AppRoutes.verifyUser);
      Utils.successSnackBar(AppString.successful, AppString.successful_send_otp);
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoadingWork = false;
    update();
  }
}