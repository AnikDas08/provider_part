import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import '../../../../../services/api/api_response_model.dart';
import '../../../../../services/api/api_service.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ServicePair {
  TextEditingController serviceController = TextEditingController();
  TextEditingController serviceTypeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String? selectedCategoryId;
  String? selectedSubCategoryId;
}

class CompleteProfileController extends GetxController {
  // Controllers
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController pricePerHourController = TextEditingController();

  // Observables
  var profileImage = Rxn<File>();
  RxList<String> uploadedImages = <String>[].obs;
  var serviceDistance = 0.0.obs;
  var isPrivacyAccepted = false.obs;
  var selectedLanguages = <String>[].obs;
  var servicePairs = <ServicePair>[].obs;

  // API Data
  var categories = <Map<String, dynamic>>[].obs;
  var subCategoriesMap = <String, List<Map<String, dynamic>>>{}.obs;
  var isLoadingSubCategories = <String, bool>{}.obs;
  var isUploadingImage = false.obs;
  var isSubmitting = false.obs;

  // Location
  double latitude = 0.0;
  double longitude = 0.0;

  // Static Data
  final languages = [AppString.english_language,AppString.russian_language,AppString.serbian_language,AppString.german_language,AppString.spanish_language,AppString.portugue_language];

  @override
  void onInit() {
    super.onInit();
    addService();
    requestPermissionsAndFetchLocation();
    fetchCategories();
  }

  // ----------------- API Calls -----------------
  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.category,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          categories.value = List<Map<String, dynamic>>.from(data['data']);
          print("Categories loaded: ${categories.length}");
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
      //Get.snackbar("Error", "Failed to load categories");
    }
  }

  Future<void> fetchSubCategories(String categoryId) async {
    try {
      isLoadingSubCategories[categoryId] = true;
      isLoadingSubCategories.refresh();

      print("Fetching subcategories for category: $categoryId");

      final response = await ApiService.get(
        "${ApiEndPoint.subCategory}?category=$categoryId",
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      print("Subcategory response status: ${response.statusCode}");
      print("Subcategory response data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          subCategoriesMap[categoryId] = List<Map<String, dynamic>>.from(
            data['data'],
          );
          subCategoriesMap.refresh();
          print(
            "Subcategories loaded: ${subCategoriesMap[categoryId]?.length ?? 0}",
          );
        } else {
          print("No subcategories found for category: $categoryId");
          subCategoriesMap[categoryId] = [];
          subCategoriesMap.refresh();
        }
      } else {
        print("Failed to fetch subcategories. Status: ${response.statusCode}");
        //Get.snackbar("Error", "Failed to load subcategories");
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
      //Get.snackbar("Error", "Failed to load subcategories: $e");
      subCategoriesMap[categoryId] = [];
      subCategoriesMap.refresh();
    } finally {
      isLoadingSubCategories[categoryId] = false;
      isLoadingSubCategories.refresh();
    }
  }

  Future<void> updateProfileImage() async {
    if (profileImage.value == null) return;

    try {
      isUploadingImage.value = true;

      await ApiService.multipart(
        "user/update-profile-image",
        method: "PATCH",
        imageName: "image",
        imagePath: profileImage.value!.path,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );
    } catch (e) {
      print("Error updating profile image: $e");
    } finally {
      isUploadingImage.value = false;
    }
  }

  List<Map<String, dynamic>> getSubCategoriesForCategory(String categoryId) {
    return subCategoriesMap[categoryId] ?? [];
  }

  bool isSubCategoriesLoading(String categoryId) {
    return isLoadingSubCategories[categoryId] ?? false;
  }

  // ----------------- Permissions & Location -----------------
  Future<void> requestPermissionsAndFetchLocation() async {
    await _requestLocationPermission();
    await getCurrentLocation();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //Get.snackbar("Error", "Location services are disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      /*Get.snackbar(
        "Error",
        "Location permissions are permanently denied, cannot fetch location.",
      );*/
      return;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      print("Location fetched - Lat: $latitude, Long: $longitude");
      update();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to get location: $e",
        backgroundColor: Colors.red[100],
      );
    }
  }

  // ----------------- Service Management -----------------
  void addService() {
    servicePairs.add(ServicePair());
  }

  void deleteService(int index) {
    if (index < servicePairs.length) servicePairs.removeAt(index);
  }

  void onCategorySelected(
      int pairIndex,
      String categoryId,
      String categoryName,
      ) async {
    if (pairIndex < servicePairs.length) {
      print("Category selected: $categoryName (ID: $categoryId)");

      servicePairs[pairIndex].selectedCategoryId = categoryId;
      servicePairs[pairIndex].serviceController.text = categoryName;
      servicePairs[pairIndex].selectedSubCategoryId = null;
      servicePairs[pairIndex].serviceTypeController.clear();

      await fetchSubCategories(categoryId);
      update();
    }
  }

  void onSubCategorySelected(
      int pairIndex,
      String subCategoryId,
      String subCategoryName,
      ) {
    if (pairIndex < servicePairs.length) {
      print("Subcategory selected: $subCategoryName (ID: $subCategoryId)");

      servicePairs[pairIndex].selectedSubCategoryId = subCategoryId;
      servicePairs[pairIndex].serviceTypeController.text = subCategoryName;
      update();
    }
  }

  void selectFromDropdown(TextEditingController controller, String value) {
    controller.text = value;
    update();
  }

  // ----------------- Image Upload -----------------
  Future<void> handleImageUpload() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) profileImage.value = File(picked.path);
  }

  Future<void> handleWorkPhotosUpload() async {
    try {
      final picked = await ImagePicker().pickMultiImage();
      if (picked.isNotEmpty) {
        // Check if adding these images would exceed the limit
        int remainingSlots = 10 - uploadedImages.length;

        if (picked.length > remainingSlots) {
          Get.snackbar(
            "Warning",
            "You can only upload $remainingSlots more image(s). Only the first $remainingSlots images will be added.",
            backgroundColor: Colors.orange[100],
          );
        }

        // Add only the allowed number of images
        int imagesToAdd = picked.length > remainingSlots ? remainingSlots : picked.length;
        for (int i = 0; i < imagesToAdd; i++) {
          uploadedImages.add(picked[i].path);
        }

        print("Total uploaded images: ${uploadedImages.length}");
      }
    } catch (e) {
      print("Error picking images: $e");
      Get.snackbar(
        AppString.error,
        "${AppString.failed_image}: $e",
        backgroundColor: Colors.red[100],
      );
    }
  }

  void removeWorkPhoto(int index) {
    if (index < uploadedImages.length) {
      uploadedImages.removeAt(index);
      print("Image removed. Total images: ${uploadedImages.length}");
    }
  }

  // ----------------- Languages -----------------
  void toggleLanguageSelection(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
  }

  bool isLanguageSelected(String language) {
    return selectedLanguages.contains(language);
  }

  // ----------------- Slider -----------------
  void updateServiceDistance(double value) {
    serviceDistance.value = value;
  }

  // ----------------- Privacy -----------------
  void togglePrivacyAcceptance() {
    isPrivacyAccepted.value = !isPrivacyAccepted.value;
  }

  // ----------------- Validation -----------------
  bool validateForm() {
    if (aboutMeController.text.isEmpty) {
      Get.snackbar(AppString.about_me, AppString.about_me_required);
      return false;
    }
    if (locationController.text.isEmpty) {
      Get.snackbar(AppString.error, AppString.primary_location_required);
      return false;
    }
    if (latitude == 0.0 || longitude == 0.0) {
      /*Get.snackbar(
        "Error",
        "Location coordinates not available. Please enable GPS.",
      );*/
      return false;
    }
    if (!isPrivacyAccepted.value) {
      Get.snackbar(AppString.error, AppString.pricacy_policy_required);
      return false;
    }
    if (servicePairs.any(
          (pair) =>
      pair.selectedCategoryId == null ||
          pair.selectedSubCategoryId == null ||
          pair.priceController.text.isEmpty,
    )) {
      Get.snackbar(AppString.error, AppString.service_all_required);
      return false;
    }
    if (uploadedImages.isEmpty) {
      Get.snackbar(AppString.error, AppString.service_image_update);
      return false;
    }
    return true;
  }

  // ----------------- Post Profile -----------------
  Future<void> confirmProfile() async {
    if (!validateForm()) return;

    if (isSubmitting.value) {
      print("Already submitting...");
      return;
    }

    await _postProviderProfile();
  }

  Future<void> _postProviderProfile() async {
    try {
      isSubmitting.value = true;

      print("=== Starting Profile Upload ===");
      print("Total service images to upload: ${uploadedImages.length}");

      // Prepare data object
      Map<String, dynamic> dataObj = {
        "aboutMe": aboutMeController.text.trim(),
        "serviceLanguage": selectedLanguages.toList(),
        "primaryLocation": locationController.text.trim(),
        "location": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "serviceDistance": serviceDistance.value,
        "pricePerHour":
        double.tryParse(pricePerHourController.text.trim()) ?? 0.0,
        "isRead": isPrivacyAccepted.value,
      };

      // Prepare services array
      List<Map<String, dynamic>> servicesArray = servicePairs.map((pair) {
        return {
          "category": pair.selectedCategoryId ?? "",
          "subCategory": pair.selectedSubCategoryId ?? "",
          "price": double.tryParse(pair.priceController.text.trim()) ?? 0.0,
        };
      }).toList();

      print("Data object: ${jsonEncode(dataObj)}");
      print("Services array: ${jsonEncode(servicesArray)}");

      // Create FormData
      FormData formData = FormData();

      // Add text fields
      formData.fields.add(MapEntry("data", jsonEncode(dataObj)));
      formData.fields.add(MapEntry("services", jsonEncode(servicesArray)));

      // Add multiple service images
      for (int i = 0; i < uploadedImages.length; i++) {
        String imagePath = uploadedImages[i];
        File imageFile = File(imagePath);

        if (await imageFile.exists()) {
          // Get MIME type
          String? mimeType = lookupMimeType(imagePath);
          String contentType = mimeType ?? 'image/jpeg';
          List<String> mimeTypeParts = contentType.split('/');

          print("Adding image ${i + 1}: $imagePath (MIME: $contentType)");

          // Add image to FormData with the field name "serviceImages"
          formData.files.add(
            MapEntry(
              "serviceImages",  // Field name must match backend expectation
              await MultipartFile.fromFile(
                imagePath,
                filename: imageFile.path.split('/').last,
                contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
              ),
            ),
          );
        } else {
          print("Warning: Image file does not exist: $imagePath");
        }
      }

      print("FormData fields: ${formData.fields.length}");
      print("FormData files: ${formData.files.length}");

      // Make API request using Dio
      final response = await _makeMultipartRequest(
        ApiEndPoint.provider,
        formData,
        {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          AppString.successful,
          AppString.profile_upload_successfully,
          backgroundColor: Colors.green[100],
        );

        // Update profile image if selected
        if (profileImage.value != null) {
          await updateProfileImage();
        }

        // Navigate to home
        Get.offAllNamed(AppRoutes.homeNav);
      } else {
        String errorMessage = "Failed to upload profile";

        if (response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
          //errorMessage = response.data;
        }
      
        Get.snackbar(
          AppString.error,
          errorMessage,
          backgroundColor: Colors.red[100],
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print("Error in _postProviderProfile: $e");
      Get.snackbar(
        AppString.error,
        "Failed to send profile: $e",
        backgroundColor: Colors.red[100],
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Custom method to handle FormData with multiple images
  Future<ApiResponseModel> _makeMultipartRequest(
      String url,
      FormData formData,
      Map<String, String> headers,
      ) async {
    try {
      Dio dio = Dio();
      // Configure Dio
      dio.options.baseUrl = ApiEndPoint.baseUrl;
      dio.options.connectTimeout = const Duration(seconds: 60);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.sendTimeout = const Duration(seconds: 60);

      print("Making request to: ${dio.options.baseUrl}$url");

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            ...headers,
            "Content-Type": "multipart/form-data",
          },
          validateStatus: (status) => status! < 500,
        ),
        onSendProgress: (sent, total) {
          double progress = (sent / total) * 100;
          print("Upload progress: ${progress.toStringAsFixed(2)}%");
        },
      );

      print("Response received - Status: ${response.statusCode}");

      return ApiResponseModel(
        response.statusCode ?? 500,
        response.data,
      );
    } on DioException catch (error) {
      print("DioException occurred: ${error.type}");
      print("Error message: ${error.message}");
      print("Error response: ${error.response?.data}");

      if (error.type == DioExceptionType.badResponse) {
        return ApiResponseModel(
          error.response?.statusCode ?? 500,
          error.response?.data ?? {"message": "Bad response from server"},
        );
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return ApiResponseModel(
          408,
          {"message": "Connection timeout. Please check your internet connection."},
        );
      } else if (error.type == DioExceptionType.sendTimeout) {
        return ApiResponseModel(
          408,
          {"message": "Upload timeout. Files may be too large."},
        );
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return ApiResponseModel(
          408,
          {"message": "Server response timeout. Please try again."},
        );
      }

      return ApiResponseModel(
        500,
        {"message": "Request failed: ${error.message}"},
      );
    } catch (e) {
      print("Unknown error occurred: $e");
      return ApiResponseModel(
        500,
        {"message": "Unknown error occurred: $e"},
      );
    }
  }

  @override
  void onClose() {
    aboutMeController.dispose();
    locationController.dispose();
    pricePerHourController.dispose();
    for (var pair in servicePairs) {
      pair.serviceController.dispose();
      pair.serviceTypeController.dispose();
      pair.priceController.dispose();
    }
    super.onClose();
  }
}