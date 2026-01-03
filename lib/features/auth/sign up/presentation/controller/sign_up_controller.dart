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
  final String displayName; // full name
  final String lat;
  final String lon;
  final String shortName; // City, State, Country dynamically

  LocationModel({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.shortName,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};
    String city = address['city'] ?? address['town'] ?? address['village'] ?? '';
    String state = address['state'] ?? '';
    String country = address['country'] ?? '';

    String shortName = '';
    if (city.isNotEmpty && state.isNotEmpty && country.isNotEmpty) {
      shortName = "$city, $state, $country";
    } else {
      // fallback if address not available
      List<String> parts = (json['display_name'] as String).split(',');
      shortName = parts.take(3).map((e) => e.trim()).join(', ');
    }

    return LocationModel(
      displayName: json['display_name'],
      lat: json['lat'],
      lon: json['lon'],
      shortName: shortName,
    );
  }
}


class SignUpController extends GetxController {
  /// Sign Up Form Key
  final signUpFormKey = GlobalKey<FormState>();

  bool isPopUpOpen = false;
  bool isLoading = false;
  bool isLoadingVerify = false;
  bool isLoadingWork=false;
  String completePhoneNumber = ''; // Stores phone with country code
  String countryCode = '+880'; // Stores selected country code
  String countryFlag = '🇧🇩';

  List<LocationModel> locationSuggestions = [];
  bool isLocationLoading = false;
  String? latitude;
  String? longitude;
  Timer? _debounce;

  /// Call this when user types in the location field
  void onLocationChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchLocation(value);
    });
  }
  //String time = "";

  List selectedOption = ["User", "Consultant"];

  String? image;

  String signUpToken = '';

  static SignUpController get instance => Get.put(SignUpController());

  TextEditingController nameController = TextEditingController(
    text: kDebugMode ? "Namimul Hassan" : "",
  );
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? "developernaimul00@gmail.com" : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );
  TextEditingController confirmPasswordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );
  TextEditingController phoneNumberController = TextEditingController(
    text: kDebugMode ? '1865965581' : '',
  );
  TextEditingController otpController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  TextEditingController locationController = TextEditingController(
    text: kDebugMode ? 'Dhaka' : '',
  );
  TextEditingController referralController = TextEditingController(
    text: kDebugMode ? '23456' : '',
  );


  @override
  void dispose() {
    //_timer?.cancel();
    super.dispose();
  }

  onCountryChange(Country value) {
    update();
    countryCode = value.dialCode.toString();
    print("😍😍😍😍 $countryCode");
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
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5'

    );

    final response = await http.get(url, headers: {"User-Agent": "HaircutMenApp"});

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      locationSuggestions = data.map((e) => LocationModel.fromJson(e)).toList();
    } else {
      locationSuggestions.clear();
    }

    isLocationLoading = false;
    update();
  }

  /// Call this when user selects a location from suggestions
  void selectLocation(LocationModel location) {
    locationController.text = location.shortName; // show only short name
    latitude = location.lat;
    longitude = location.lon;
    locationSuggestions.clear();
    update();
  }

  signUpUser() async {
    if (!signUpFormKey.currentState!.validate()) return;
    //Get.toNamed(AppRoutes.verifyUser);
    print("Country code 😍😍😍😍 $countryCode");
    isLoading = true;
    update();
    Map<String, String> body = {
      "role":"PROVIDER",
      "name":nameController.text,
      "email":emailController.text,
      "contact": phoneNumberController.text,
      "countryCode":countryCode,
      "location":locationController.text,
      "password": passwordController.text,
      "referralCode":referralController.text,
    };

    var response = await ApiService.post(ApiEndPoint.signUp, body: body);

    if (response.statusCode == 200) {
      var data = response.data;
      //signUpToken = data['data']['signUpToken'];
      Get.toNamed(AppRoutes.verifyUser);
    } else if(response.statusCode==409) {
      Get.offAllNamed(AppRoutes.signIn);
      Get.snackbar(
          response.statusCode.toString(), AppString.user_exits);
    }
    else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoading = false;
    update();
  }


  /*void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    start = 180; // Reset the start value
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        start--;
        final minutes = (start ~/ 60).toString().padLeft(2, '0');
        final seconds = (start % 60).toString().padLeft(2, '0');

        time = "$minutes:$seconds";

        update();
      } else {
        _timer?.cancel();
      }
    });
  }*/

  Future<void> verifyOtpRepo() async {
    //Get.offAllNamed(AppRoutes.signIn);
    //return;

    isLoadingVerify = true;
    update();
    print("email is : ${emailController.text}");
    print("otp is : ${otpController.text}");
    Map<String, String> body =
    {
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
      var data = response.data;
      Get.offAllNamed(AppRoutes.signIn);

      /*LocalStorage.token = data['data']["accessToken"];
      LocalStorage.userId = data['data']["attributes"]["_id"];
      LocalStorage.myImage = data['data']["attributes"]["image"];
      LocalStorage.myName = data['data']["attributes"]["fullName"];
      LocalStorage.myEmail = data['data']["attributes"]["email"];
      LocalStorage.isLogIn = true;

      LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
      LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
      LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
      LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
      LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName);
      LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail);*/

      // if (LocalStorage.myRole == 'consultant') {
      //   Get.toNamed(AppRoutes.personalInformation);
      // } else {
      //   Get.offAllNamed(AppRoutes.patientsHome);
      // }
    }
    else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoadingVerify = false;
    update();
  }

  resetOpt() async {
    //Get.toNamed(AppRoutes.verifyUser);
    isLoadingWork = true;
    update();
    Map<String, String> body = {
      "email":emailController.text,
    };

    var response = await ApiService.post(ApiEndPoint.reset_otp, body: body);

    if (response.statusCode == 200) {
      var data = response.data;
      //signUpToken = data['data']['signUpToken'];
      Get.toNamed(AppRoutes.verifyUser);
      Utils.successSnackBar(AppString.successful, AppString.successful_send_otp);
    }
    else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoadingWork = false;
    update();
  }
}
