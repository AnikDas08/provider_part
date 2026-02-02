import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/profile/data/provider_model.dart';
import 'package:haircutmen_user_app/services/api/api_service.dart';
import 'package:http/http.dart' as http;
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

  // Track if this service has been modified
  bool isModified = false;

  void dispose() {
    serviceController.dispose();
    serviceTypeController.dispose();
    priceController.dispose();
  }
}

class LocationModel {
  final String displayName;
  final String lat;
  final String lon;
  final String shortName;

  LocationModel({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.shortName,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};

    String shortName = address['suburb'] ??
        address['neighbourhood'] ??
        address['road'] ??
        address['city'] ??
        address['town'] ??
        address['village'] ??
        address['state'] ??
        '';

    if (shortName.isEmpty) {
      List<String> parts = (json['display_name'] as String).split(',');
      shortName = parts.first.trim();
    }

    return LocationModel(
      displayName: json['display_name'],
      lat: json['lat'],
      lon: json['lon'],
      shortName: shortName,
    );
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
  RxBool isInitializing = true.obs;
  List<LocationModel> locationSuggestions = [];
  bool isLocationLoading = false;

  // API Data
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
      final pair = servicePairs[index];

      print("=== Removing Service at Index $index ===");
      print("Service ID: ${pair.serviceId}");
      print("Service Name: ${pair.serviceController.text}");

      pair.dispose();
      servicePairs.removeAt(index);

      print("Remaining services: ${servicePairs.length}");
      update();
    } else {
      Get.snackbar(
        "Cannot Delete",
        "You must have at least one service",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      isInitializing.value = true;

      getCurrentLocation().catchError((error) {
        print("Location error: $error");
      });

      await fetchCategories().timeout(Duration(seconds: 15));
      await getProviderInformation().timeout(Duration(seconds: 15));

      isLoading.value = false;
    } catch (e) {
      Get.snackbar("Error", "Failed to load data");
      if (servicePairs.isEmpty) {
        servicePairs.add(ServicePair());
      }
    }
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
    _debounceLocation?.cancel();
    for (var pair in servicePairs) {
      pair.dispose();
    }
    super.onClose();
  }

  Timer? _debounceLocation;

  void onLocationChanged(String value) {
    _debounceLocation?.cancel();
    _debounceLocation = Timer(const Duration(milliseconds: 500), () {
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
    locationController.text = location.displayName;
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

  void togglePrivacyAcceptance() {
    isPrivacyAccepted.value = !isPrivacyAccepted.value;
  }

  int getTotalImageCount() {
    return assetImages.length + uploadedImages.length;
  }

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
        // Mark as modified when service is changed
        pair.isModified = true;
        pair.serviceTypeController.clear();
        pair.subCategoryId = null;

        final category = categories.firstWhereOrNull(
              (cat) => cat['name'] == value,
        );

        if (category != null) {
          String categoryId = category['_id'] ?? category['id'] ?? '';
          pair.categoryId = categoryId;

          if (categoryId.isNotEmpty) {
            await fetchSubCategories(categoryId);
          }
        }
        break;
      } else if (pair.serviceTypeController == controller) {
        // Mark as modified when service type is changed
        pair.isModified = true;
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

      print("\n========================================");
      print("STARTING PROFILE UPDATE");
      print("========================================");
      print("Total services in form: ${servicePairs.length}");

      // Build new services array (services without serviceId)
      List<Map<String, dynamic>> newServices = [];

      // Build update services array (services with serviceId that are modified)
      List<Map<String, dynamic>> updateServices = [];

      // Build exist array (service IDs that exist but are NOT modified)
      List<String> existServices = [];

      for (var pair in servicePairs) {
        double? price = double.tryParse(pair.priceController.text.trim());
        if (price == null) continue;

        if (pair.serviceId == null || pair.serviceId!.isEmpty) {
          // New service (no ID)
          newServices.add({
            "category": pair.categoryId,
            "subCategory": pair.subCategoryId,
            "price": price.toInt(),
          });
          print("✨ New service: ${pair.serviceController.text} - ${pair.serviceTypeController.text}");
        } else {
          // Existing service (has ID)
          if (pair.isModified) {
            // Service is modified - add to UPDATE array
            updateServices.add({
              "ref": pair.serviceId,
              "category": pair.categoryId,
              "subCategory": pair.subCategoryId,
              "price": price.toInt(),
            });
            print("🔄 Updated service: ${pair.serviceController.text} - ${pair.serviceTypeController.text} (ID: ${pair.serviceId})");
          } else {
            // Service exists but not modified - add to EXIST array
            existServices.add(pair.serviceId!);
            print("✅ Existing service (unchanged): ${pair.serviceController.text} - ${pair.serviceTypeController.text} (ID: ${pair.serviceId})");
          }
        }
      }

      print("\n--- Service Summary ---");
      print("New services to add: ${newServices.length}");
      print("Existing services to update: ${updateServices.length}");
      print("Existing services (unchanged): ${existServices.length}");
      print("Existing IDs (unchanged): ${existServices}");

      // Build services OBJECT with new, update, and exist arrays
      Map<String, dynamic> servicesObject = {
        "new": newServices,
        "update": updateServices,
        "exist": existServices,
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
        "serviceDistance": serviceDistance.value.toInt(),
        "pricePerHour": (double.tryParse(pricePerHourController.text.trim()) ?? 0).toInt(),
        "isRead": true,
      };

      print("\n--- Data Object ---");
      print(jsonEncode(dataObject));

      print("\n--- Services Object ---");
      print(jsonEncode(servicesObject));

      // Create FormData
      FormData formData = FormData();

      // Add data as JSON string
      formData.fields.add(MapEntry('data', jsonEncode(dataObject)));

      // Add services as JSON OBJECT string
      String servicesJson = jsonEncode(servicesObject);
      formData.fields.add(MapEntry('services', servicesJson));

      print("\n--- Services JSON Being Sent ---");
      print(servicesJson);

      // Add previousServiceImages as JSON array string
      if (assetImages.isNotEmpty) {
        formData.fields.add(MapEntry('previousServiceImages', jsonEncode(assetImages.toList())));
        print("\n--- Previous Images ---");
        print("Count: ${assetImages.length}");
      }

      // Add new service images as files (if any)
      if (uploadedImages.isNotEmpty) {
        print("\n--- New Images ---");
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

      print("\n--- Making API Call ---");
      print("Endpoint: ${ApiEndPoint.baseUrl}${ApiEndPoint.provider}");
      print("Method: PUT");

      // Make API call
      final response = await _makeMultipartRequest(
        ApiEndPoint.provider,
        formData,
        {"Authorization": "Bearer $token"},
      );

      print("\n========================================");
      print("API RESPONSE");
      print("========================================");
      print("Status Code: ${response.statusCode}");
      print("Response: ${jsonEncode(response.data)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("\n✅ SUCCESS - Profile updated successfully");

        Get.snackbar(
          "Success",
          "Your profile has been updated successfully",
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

        print("\n❌ ERROR - ${errorMessage}");
        Utils.errorSnackBar(0, errorMessage);
      }
    } catch (e) {
      print("\n❌ EXCEPTION in confirmProfile");
      print("Error: $e");
      Utils.errorSnackBar(0, "Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

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
    print("\n========================================");
    print("POPULATING FORM WITH PROVIDER DATA");
    print("========================================");

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
      serviceDistance.value = data.serviceDistance!.toDouble().clamp(0.0, 100.0);
    }

    if (data.pricePerHour != null) {
      pricePerHourController.text = data.pricePerHour!.toString();
    }

    // Clear existing services
    for (var pair in servicePairs) {
      pair.dispose();
    }
    servicePairs.clear();

    if (data.services != null && data.services!.isNotEmpty) {
      print("\nLoading ${data.services!.length} existing services:");
      for (var service in data.services!) {
        ServicePair pair = ServicePair();
        pair.serviceId = service.id;
        pair.categoryId = service.category?.id;
        pair.subCategoryId = service.subCategory?.id;
        pair.isModified = false; // Initially not modified

        if (service.category?.name != null) {
          pair.serviceController.text = service.category!.name!;
        }

        if (service.subCategory?.name != null) {
          pair.serviceTypeController.text = service.subCategory!.name!;
        }

        if (service.price != null) {
          pair.priceController.text = service.price!.toString();
        }

        // Add listener to detect price changes
        pair.priceController.addListener(() {
          pair.isModified = true;
        });

        servicePairs.add(pair);

        print("  - ${service.category?.name ?? 'N/A'} > ${service.subCategory?.name ?? 'N/A'} (ID: ${service.id})");

        if (pair.categoryId != null && pair.categoryId!.isNotEmpty) {
          fetchSubCategories(pair.categoryId!);
        }
      }
    } else {
      servicePairs.add(ServicePair());
      print("No existing services, added empty service pair");
    }

    assetImages.clear();
    uploadedImages.clear();
    if (data.serviceImages != null && data.serviceImages!.isNotEmpty) {
      assetImages.addAll(data.serviceImages!);
    }

    print("\n--- Form Population Complete ---");
    print("Services loaded: ${servicePairs.length}");
    print("Images loaded: ${assetImages.length}");
    print("========================================\n");
    update();
  }
}