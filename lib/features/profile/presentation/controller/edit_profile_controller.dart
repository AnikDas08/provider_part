import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/helpers/other_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../data/profile_model.dart';

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

  // Country code with observable
  var countryCode = "+880".obs; // Default to Bangladesh
  var countryDialCode = "+880";
  var countryFlag = "🇧🇩".obs; // Default Bangladesh flag
  var countryIsoCode = "BD".obs; // Default country ISO code
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

  List<String> locations = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
    'San Antonio',
    'San Diego',
    'Dallas',
    'San Jose',
    'Austin',
    'Jacksonville',
    'Fort Worth',
    'Columbus',
    'Charlotte',
    'San Francisco',
    'Indianapolis',
    'Seattle',
    'Denver',
    'Boston',
    // Add more locations as needed
  ];

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

  @override
  void onInit() {
    super.onInit();
    getProfile();
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
      // Show bottom sheet for image source selection
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
      // Combine country code with phone number
      fullNumber = countryDialCode + numberController.text.trim();

      // Prepare body
      Map<String, String> body = {
        "name": nameController.text.trim(),
        "contact": numberController.text.trim(),
        "countryCode": countryDialCode,
        "location": primaryLocationController.text.trim(),
      };

      String? imagePath = profileImage.value?.path;

      final response = await ApiService.multipart(
        ApiEndPoint.user,
        header: {"Authorization": "Bearer $token"},
        body: body,
        method: "PATCH", // since you want to update
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