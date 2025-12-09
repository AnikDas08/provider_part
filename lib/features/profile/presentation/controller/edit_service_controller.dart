import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/profile/data/provider_model.dart';
import 'package:haircutmen_user_app/services/api/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../../services/api/api_response_model.dart';

import 'dart:convert';

class ServicePair {
  TextEditingController serviceController = TextEditingController();
  TextEditingController serviceTypeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String? serviceId;
  String? categoryId;
  String? subCategoryId;

  void dispose() {
    serviceController.dispose();
    serviceTypeController.dispose();
    priceController.dispose();
  }
}

class EditServiceController extends GetxController {
  // Text Controllers
  final TextEditingController aboutMeController = TextEditingController();
  final TextEditingController serviceTypeController = TextEditingController();
  final TextEditingController additionalServiceController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController pricePerHourController = TextEditingController();

  // Observable variables
  RxNum serviceDistance = RxNum(0);
  RxBool isPrivacyAccepted = false.obs;
  RxList<String> uploadedImages = <String>[].obs;
  Rx<File?> profileImage = Rx<File?>(null);
  RxBool isLoading = true.obs;

  // Provider data
  Rx<ProviderData?> providerData = Rx<ProviderData?>(null);

  // Service pairs
  RxList<ServicePair> servicePairs = <ServicePair>[].obs;
  RxList<String> selectedLanguages = <String>[].obs;

  // API Data - Changed to use Map format like complete profile controller
  var categories = <Map<String, dynamic>>[].obs;
  var subCategoriesMap = <String, List<Map<String, dynamic>>>{}.obs;
  var isLoadingSubCategories = <String, bool>{}.obs;

  // Default coordinates (Dhaka, Bangladesh)
  double latitude = 23.8103;
  double longitude = 90.4125;

  // Asset images (can be modified/removed)
  RxList<String> assetImages = <String>[].obs;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Get service names from categories
  List<String> get serviceNames {
    if (categories.isNotEmpty) {
      return categories
          .map((cat) => cat['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }
    return [];
  }

  // Get service types for a specific service
  List<String> getServiceTypes(String serviceName) {
    // Find the category
    final category = categories.firstWhereOrNull(
          (cat) => cat['name'] == serviceName,
    );

    if (category != null) {
      String categoryId = category['_id'] ?? category['id'] ?? '';
      if (categoryId.isNotEmpty) {
        final subCategories = subCategoriesMap[categoryId] ?? [];
        return subCategories
            .map((sub) => (sub['subCategoryName'] ?? sub['name'])?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
    }

    return [];
  }

  final List<String> languages = [
    'English',
    'Russian',
    'Serbian',
    "German",
    "Spanish",
    "Portuguese"
  ];

  bool isLanguageSelected(String language) {
    return selectedLanguages.contains(language);
  }

  void toggleLanguageSelection(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
    languageController.text = selectedLanguages.join(', ');
    update();
  }

  void selectLanguageFromDropdown(String language) {
    toggleLanguageSelection(language);
  }

  void addService() {
    servicePairs.add(ServicePair());
    update();
  }

  void removeService(int index) {
    if (servicePairs.length > 1) {
      servicePairs[index].dispose();
      servicePairs.removeAt(index);
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories(); // Fetch all categories first
    getProviderInformation();
    getCurrentLocation();
  }

  @override
  void onClose() {
    aboutMeController.dispose();
    serviceTypeController.dispose();
    additionalServiceController.dispose();
    languageController.dispose();
    locationController.dispose();
    priceController.dispose();
    pricePerHourController.dispose();
    for (var pair in servicePairs) {
      pair.dispose();
    }
    super.onClose();
  }

  void togglePrivacyAcceptance() {
    isPrivacyAccepted.value = !isPrivacyAccepted.value;
  }

  int getTotalImageCount() {
    return assetImages.length + uploadedImages.length;
  }

  // Fetch all categories from API
  Future<void> fetchCategories() async {
    try {
      print("Fetching all categories...");

      final response = await ApiService.get(
        ApiEndPoint.category,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          categories.value = List<Map<String, dynamic>>.from(data['data']);
          print("All categories loaded: ${categories.length}");
          update();
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
      Get.snackbar("Error", "Failed to load categories");
    }
  }

  // Fetch subcategories for a specific category
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
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
      subCategoriesMap[categoryId] = [];
      subCategoriesMap.refresh();
    } finally {
      isLoadingSubCategories[categoryId] = false;
      isLoadingSubCategories.refresh();
    }
  }

  List<Map<String, dynamic>> getSubCategoriesForCategory(String categoryId) {
    return subCategoriesMap[categoryId] ?? [];
  }

  bool isSubCategoriesLoading(String categoryId) {
    return isLoadingSubCategories[categoryId] ?? false;
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      latitude = position.latitude;
      longitude = position.longitude;

      print("Location fetched - Lat: $latitude, Long: $longitude");
      update();
    } catch (e) {
      print("Failed to get location: $e (using default coordinates)");
    }
  }

  List<Map<String, dynamic>> getAllImages() {
    List<Map<String, dynamic>> allImages = [];
    for (String assetPath in assetImages) {
      allImages.add({'type': 'asset', 'path': assetPath});
    }
    for (String uploadedPath in uploadedImages) {
      allImages.add({'type': 'file', 'path': uploadedPath});
    }
    return allImages;
  }

  void updateServiceDistance(double value) {
    serviceDistance.value = value;
    update();
  }

  void selectFromDropdown(TextEditingController controller, String value) async {
    controller.text = value;

    for (var pair in servicePairs) {
      if (pair.serviceController == controller) {
        // Service selected - clear service type and update category ID
        pair.serviceTypeController.clear();
        pair.subCategoryId = null;

        // Find category by name
        final category = categories.firstWhereOrNull(
              (cat) => cat['name'] == value,
        );

        if (category != null) {
          String categoryId = category['_id'] ?? category['id'] ?? '';
          pair.categoryId = categoryId;

          // Fetch subcategories for this category
          if (categoryId.isNotEmpty) {
            await fetchSubCategories(categoryId);
          }
        }
        break;
      } else if (pair.serviceTypeController == controller) {
        // Service type selected - update subcategory ID
        final categoryId = pair.categoryId;
        if (categoryId != null && categoryId.isNotEmpty) {
          final subCategories = subCategoriesMap[categoryId] ?? [];
          final subCategory = subCategories.firstWhereOrNull(
                (sub) => (sub['subCategoryName'] ?? sub['name']) == value,
          );
          if (subCategory != null) {
            String subCategoryId = subCategory['_id'] ?? subCategory['id'] ?? '';
            pair.subCategoryId = subCategoryId;
            print("SubCategory selected: $value (ID: $subCategoryId)");
          }
        }
        break;
      }
    }
    update();
  }

  void removeAssetImage(int index) {
    if (index >= 0 && index < assetImages.length) {
      assetImages.removeAt(index);
      update();
    }
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
      Container(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                        child: Icon(Icons.camera_alt, size: 32, color: Colors.blue),
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
                        child: Icon(Icons.photo_library, size: 32, color: Colors.green),
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
  }

  Future<void> handleWorkPhotosUpload() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        if (getTotalImageCount() + pickedFiles.length > 10) {
          Get.snackbar(
            "Error",
            "Maximum 10 images allowed. You can add ${10 - getTotalImageCount()} more images.",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        for (XFile file in pickedFiles) {
          uploadedImages.add(file.path);
        }

        Get.snackbar(
          "Success",
          "${pickedFiles.length} image(s) uploaded successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload work photos: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeWorkPhoto(int index) {
    if (index >= 0 && index < uploadedImages.length) {
      uploadedImages.removeAt(index);
      update();
    }
  }

  bool validateForm() {
    if (aboutMeController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter About Me");
      return false;
    }

    if (selectedLanguages.isEmpty) {
      Get.snackbar("Error", "Please select at least one language");
      return false;
    }

    if (locationController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Primary Location");
      return false;
    }

    if (pricePerHourController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Price Per Hour");
      return false;
    }

    if (double.tryParse(pricePerHourController.text.trim()) == null) {
      Get.snackbar("Error", "Price Per Hour must be a valid number");
      return false;
    }

    // Check for duplicate services
    Set<String> uniqueServices = {};
    for (int i = 0; i < servicePairs.length; i++) {
      var pair = servicePairs[i];

      if (pair.serviceController.text.trim().isEmpty) {
        Get.snackbar("Error", "Please select service for Service ${i + 1}");
        return false;
      }

      if (pair.serviceTypeController.text.trim().isEmpty) {
        Get.snackbar("Error", "Please select service type for Service ${i + 1}");
        return false;
      }

      // Check for duplicate service combination
      String serviceKey = "${pair.categoryId}_${pair.subCategoryId}";
      if (uniqueServices.contains(serviceKey)) {
        Get.snackbar(
            "Error",
            "Duplicate service found: ${pair.serviceController.text} - ${pair.serviceTypeController.text}. Please remove duplicate services."
        );
        return false;
      }
      uniqueServices.add(serviceKey);

      if (pair.priceController.text.trim().isEmpty) {
        Get.snackbar("Error", "Please enter price for Service ${i + 1}");
        return false;
      }

      if (double.tryParse(pair.priceController.text.trim()) == null) {
        Get.snackbar("Error", "Price for Service ${i + 1} must be a valid number");
        return false;
      }

      if (pair.categoryId == null || pair.categoryId!.isEmpty) {
        Get.snackbar("Error", "Category not found for Service ${i + 1}");
        return false;
      }

      if (pair.subCategoryId == null || pair.subCategoryId!.isEmpty) {
        Get.snackbar("Error", "Sub-category not found for Service ${i + 1}");
        return false;
      }
    }

    return true;
  }

  Future<void> confirmProfile() async {
    if (!validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      final token = LocalStorage.token;
      if (token.isEmpty) {
        Utils.errorSnackBar(0, "Token not found, please login again");
        isLoading.value = false;
        return;
      }

      // Build new services array (services without serviceId)
      List<Map<String, dynamic>> newServices = [];
      for (var pair in servicePairs) {
        if (pair.serviceId == null) {
          double? price = double.tryParse(pair.priceController.text.trim());
          if (price != null) {
            newServices.add({
              "category": pair.categoryId,
              "subCategory": pair.subCategoryId,
              "price": price.toInt(),
            });
          }
        }
      }

      // Build update services array (services with serviceId)
      List<Map<String, dynamic>> updateServices = [];
      for (var pair in servicePairs) {
        if (pair.serviceId != null) {
          double? price = double.tryParse(pair.priceController.text.trim());
          if (price != null) {
            updateServices.add({
              "ref": pair.serviceId,
              "category": pair.categoryId,
              "subCategory": pair.subCategoryId,
              "price": price.toInt(),
            });
          }
        }
      }

      // Build services OBJECT with new and update arrays
      Map<String, dynamic> servicesObject = {
        "new": newServices,
        "update": updateServices,
      };

      // Build data object
      Map<String, dynamic> dataObject = {
        "aboutMe": aboutMeController.text.trim(),
        "serviceLanguage": selectedLanguages.toList(),
        "primaryLocation": locationController.text.trim(),
        "location": {
          "type": "Point",
          "coordinates": [longitude, latitude]
        },
        "serviceDistance": serviceDistance.value,
        "pricePerHour": (double.tryParse(pricePerHourController.text.trim()) ?? 0).toInt(),
        "isRead": true,
      };

      print("=== Edit Profile Data ===");
      print("Data Object: ${jsonEncode(dataObject)}");
      print("Services Object: ${jsonEncode(servicesObject)}");
      print("Previous Service Images: ${assetImages.toList()}");
      print("Uploaded Images Count: ${uploadedImages.length}");

      // Create FormData
      FormData formData = FormData();

      // Add data as JSON string
      formData.fields.add(MapEntry('data', jsonEncode(dataObject)));

      // Add services as JSON OBJECT string with new and update arrays
      String servicesJson = jsonEncode(servicesObject);
      print("Services JSON String: $servicesJson");
      formData.fields.add(MapEntry('services', servicesJson));

      // Add previousServiceImages as JSON array string
      if (assetImages.isNotEmpty) {
        formData.fields.add(MapEntry('previousServiceImages', jsonEncode(assetImages.toList())));
      }

      // Add new service images as files (if any)
      if (uploadedImages.isNotEmpty) {
        print("Adding ${uploadedImages.length} new service images");
        for (var imagePath in uploadedImages) {
          String fileName = imagePath.split('/').last;
          String? mimeType = lookupMimeType(imagePath);

          formData.files.add(MapEntry(
            'serviceImages',
            await MultipartFile.fromFile(
              imagePath,
              filename: fileName,
              contentType: mimeType != null
                  ? MediaType.parse(mimeType)
                  : MediaType.parse("image/jpeg"),
            ),
          ));
        }
      }

      print("=== FormData Summary ===");
      print("Fields count: ${formData.fields.length}");
      print("Files count: ${formData.files.length}");

      // Make API call
      final response = await _makeMultipartRequest(
        ApiEndPoint.provider,
        formData,
        {"Authorization": "Bearer $token"},
      );

      print("=== API Response ===");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${jsonEncode(response.data)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Your profile has been updated and is pending approval",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          duration: Duration(seconds: 3),
        );

        Future.delayed(Duration(seconds: 2), () {
          Get.offAllNamed(AppRoutes.homeNav, arguments: {"index": 0});
        });
      } else {
        String errorMessage = "Something went wrong";

        final data = response.data;

        if (data['errorMessages'] != null && data['errorMessages'] is List) {
          final errors = data['errorMessages'] as List;
          if (errors.isNotEmpty) {
            errorMessage = errors.map((e) => e['message'] ?? '').join('\n');
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }

        Utils.errorSnackBar(0, errorMessage);
      }
    } catch (e) {
      print("Error in confirmProfile: $e");
      Utils.errorSnackBar(0, "Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
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

      dio.options.baseUrl = ApiEndPoint.baseUrl;
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      dio.options.sendTimeout = const Duration(seconds: 30);

      print("=== Making Request ===");
      print("URL: ${ApiEndPoint.baseUrl}$url");
      print("Method: PUT");

      final response = await dio.put(
        url,
        data: formData,
        options: Options(
          headers: {
            ...headers,
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print("Request completed with status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponseModel(200, response.data);
      }
      return ApiResponseModel(response.statusCode, response.data);
    } on DioException catch (error) {
      print("=== DioException ===");
      print("Type: ${error.type}");
      print("Message: ${error.message}");
      print("Response: ${error.response?.data}");

      if (error.type == DioExceptionType.badResponse) {
        return ApiResponseModel(
          error.response?.statusCode,
          error.response?.data,
        );
      }
      return ApiResponseModel(500, {"message": "Request failed: ${error.message}"});
    } catch (e) {
      print("=== Unknown Error ===");
      print("Error: $e");
      return ApiResponseModel(500, {"message": "Unknown error occurred: $e"});
    }
  }

  Future<void> getProviderInformation() async {
    final token = LocalStorage.token;
    print("Fetching provider information...");

    if (token.isEmpty) {
      Utils.errorSnackBar(0, "Token not found, please login again");
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final response = await ApiService.get(
        ApiEndPoint.getProvider,
        header: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        providerData.value = ProviderData.fromJson(data);

        // Don't extract categories from provider data anymore
        // We'll use all categories from the API
        populateFormWithData(providerData.value!);

        print("Provider Data loaded successfully");
        isLoading.value = false;
        update();
      }
    } catch (e) {
      isLoading.value = false;
      Utils.errorSnackBar(0, e.toString());
      print("Error: $e");
    }
  }

  void populateFormWithData(ProviderData data) {
    if (data.aboutMe != null && data.aboutMe!.isNotEmpty) {
      aboutMeController.text = data.aboutMe!;
    }

    if (data.serviceLanguage != null && data.serviceLanguage!.isNotEmpty) {
      selectedLanguages.clear();
      selectedLanguages.addAll(data.serviceLanguage!);
      languageController.text = data.serviceLanguage!.join(', ');
    }

    if (data.primaryLocation != null && data.primaryLocation!.isNotEmpty) {
      locationController.text = data.primaryLocation!;
    }

    if (data.serviceDistance != null) {
      serviceDistance.value = data.serviceDistance!.toDouble();
    }

    if (data.pricePerHour != null) {
      pricePerHourController.text = data.pricePerHour!.toString();
    }

    for (var pair in servicePairs) {
      pair.dispose();
    }
    servicePairs.clear();

    if (data.services != null && data.services!.isNotEmpty) {
      for (var service in data.services!) {
        ServicePair pair = ServicePair();
        pair.serviceId = service.id;
        pair.categoryId = service.category?.id;
        pair.subCategoryId = service.subCategory?.id;

        if (service.category?.name != null) {
          pair.serviceController.text = service.category!.name!;
        }

        if (service.subCategory?.name != null) {
          pair.serviceTypeController.text = service.subCategory!.name!;
        }

        if (service.price != null) {
          pair.priceController.text = service.price!.toString();
        }

        servicePairs.add(pair);

        // Pre-fetch subcategories for existing services
        if (pair.categoryId != null && pair.categoryId!.isNotEmpty) {
          fetchSubCategories(pair.categoryId!);
        }
      }
    } else {
      servicePairs.add(ServicePair());
    }

    assetImages.clear();
    uploadedImages.clear();
    if (data.serviceImages != null && data.serviceImages!.isNotEmpty) {
      assetImages.addAll(data.serviceImages!);
    }

    print("Form populated - Services: ${servicePairs.length}, Images: ${assetImages.length}");
    update();
  }
}