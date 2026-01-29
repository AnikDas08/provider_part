import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/helpers/other_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../data/profile_model.dart';

// Location Model
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

    String getValue(String key) =>
        address[key]?.toString() ?? '';

    /// -------- Short Name (Most specific) --------
    String shortName =
    getValue('neighbourhood').isNotEmpty
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
        : json['display_name'];

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

class EditProfileController extends GetxController {
  /// Language List here
  List languages = ["English", "French", "Arabic"];

  /// form key here
  final formKey = GlobalKey<FormState>();

  /// select Language here
  String selectedLanguage = "English";

  /// select image here
  String? image;

  /// edit button loading here
  bool isLoading = false;

  bool isProfileLoading = false;
  ProfileData? profileData;

  // Location Autocomplete
  List<LocationModel> locationSuggestions = [];
  bool isLocationLoading = false;
  Timer? _debounce;
  double latitude = 0.0;
  double longitude = 0.0;

  // Country code with observable
  var countryCode = "+880".obs;
  var countryDialCode = "+880";
  var countryFlag = "🇧🇩".obs;
  var countryIsoCode = "BD".obs;
  var fullNumber = "";

  /// all controller here
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController primaryLocationController = TextEditingController();

  RxList<String> uploadedImages = <String>[].obs;
  Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  var selectedLocation = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ----------------- Location Autocomplete -----------------
  void onLocationChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchLocation(value);
    });
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
          '?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "HaircutMenApp"},
      );

      if (response.statusCode == 200) {
        debugPrint("RAW LOCATION RESPONSE 👉 ${response.body}");

        final List data = jsonDecode(response.body);

        debugPrint("PARSED LIST LENGTH 👉 ${data.length}");

        locationSuggestions = data.map((e) => LocationModel.fromJson(e)).toList();
      } else {
        locationSuggestions.clear();
      }
    } catch (e) {
      debugPrint("Error searching location: $e");
      locationSuggestions.clear();
    }

    isLocationLoading = false;
    update();
  }

  void selectLocation(LocationModel location) {
    primaryLocationController.text = location.displayName;
    latitude = double.parse(location.lat);
    longitude = double.parse(location.lon);
    locationSuggestions.clear();

    print("Location selected - Lat: $latitude, Lon: $longitude");
    update();
  }

  void clearLocationSuggestions() {
    locationSuggestions.clear();
    update();
  }

  void setSelectedLocation(String location) {
    selectedLocation.value = location;
  }

  // Update country code with flag
  void updateCountry(Country country) {
    countryCode.value = "+${country.phoneCode}";
    countryDialCode = "+${country.phoneCode}";
    countryFlag.value = country.flagEmoji;
    countryIsoCode.value = country.countryCode;
    update();
  }

  // Show country picker
  void openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: 500,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        updateCountry(country);
      },
    );
  }

  /// select image function here
  getProfileImage() async {
    image = await OtherHelper.openGalleryForProfile();
    update();
  }

  /// select language function here
  selectLanguage(int index) {
    selectedLanguage = languages[index];
    update();
    Get.back();
  }

  Future<void> getProfile() async {
    isProfileLoading = true;
    update();
    try {
      final response = await ApiService.get(
          ApiEndPoint.user,
          header: {"Authorization": "Bearer ${LocalStorage.token}"}
      );
      if (response.statusCode == 200) {
        final profileModel = ProfileModel.fromJson(response.data);
        print("Profile Model 😂😂😂😂😂😂😂 $profileModel");
        profileData = profileModel.data;
        print("Profile Data: $profileData");

        nameController.text = profileData?.name ?? "";
        numberController.text = profileData?.contact ?? "";
        locationController.text = profileData?.location ?? "";
        primaryLocationController.text = profileData?.location ?? "";

        // Set country code from API
        if (response.data["data"]["countryCode"] != null) {
          String apiCountryCode = response.data["data"]["countryCode"];
          countryDialCode = apiCountryCode;
          countryCode.value = apiCountryCode;

          // Get country from code to set flag
          try {
            Country country = CountryParser.parsePhoneCode(apiCountryCode.replaceAll("+", ""));
            countryFlag.value = country.flagEmoji;
            countryIsoCode.value = country.countryCode;
          } catch (e) {
            print("Could not parse country from code: $e");
          }
        }
      } else {
        Utils.errorSnackBar(response.statusCode, response.message);
      }
    } catch (e) {
      Utils.errorSnackBar(0, e.toString());
    }
    isProfileLoading = false;
    update();
  }

  Future<void> handleImageUpload() async {
    try {
      await _showImageSourceBottomSheet();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload image: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _showImageSourceBottomSheet() async {
    await Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Select Image Source",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      _pickImageFromSource(ImageSource.camera);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Camera"),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      _pickImageFromSource(ImageSource.gallery);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.photo_library,
                            size: 32,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Gallery"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        image = pickedFile.path;
        Get.snackbar(
          "Success",
          "Profile image updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    update();
  }

  /// update profile function here
  Future<void> editProfileRepo() async {
    final token = LocalStorage.token;
    if (token.isEmpty) {
      Utils.errorSnackBar(0, "Token not found, please login again");
      return;
    }

    isLoading = true;
    update();

    try {
      fullNumber = countryDialCode + numberController.text.trim();

      Map<String, dynamic> body = {
        "name": nameController.text.trim(),
        "contact": numberController.text.trim(),
        "countryCode": countryDialCode,
        "location": primaryLocationController.text.trim(),
      };

      if (latitude != null && longitude != null) {
        body["coordinates"] = longitude;
        body["coordinates"] = latitude;
      }

      String? imagePath = profileImage.value?.path;

      final response = await ApiService.multipart(
        ApiEndPoint.user,
        header: {"Authorization": "Bearer $token"},
        body: body,
        method: "PATCH",
        imageName: "image",
        imagePath: imagePath,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          profileData = profileData?.copyWith(
            name: data['name'] ?? profileData?.name,
            contact: data['contact'] ?? profileData?.contact,
            location: data['location'] ?? profileData?.location,
            image: data['image'] ?? profileData?.image,
          );
          final profileModel = ProfileModel.fromJson(response.data);
          update();
          Utils.successSnackBar(
              "Successfully Submit for Approval Your Data", response.message);
        } else {
          Utils.errorSnackBar(
              response.statusCode, "No data returned from server");
        }
      } else {
        Utils.errorSnackBar(response.statusCode, response.message);
      }
    } catch (e) {
      Utils.errorSnackBar(0, e.toString());
    }

    isLoading = false;
    update();
  }
}