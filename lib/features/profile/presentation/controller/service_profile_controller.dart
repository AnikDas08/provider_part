import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/profile/data/provider_model.dart';
import 'package:haircutmen_user_app/services/api/api_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';

class ServiceProfileController extends GetxController {
  // Observable variables
  RxString aboutMe = ''.obs;
  RxList<String> serviceLanguages = <String>[].obs;
  RxString primaryLocation = ''.obs;
  String providerId = '';
  RxNum serviceDistance = RxNum(0);
  RxDouble pricePerHour = 0.0.obs;
  RxList<String> workPhotos = <String>[].obs;
  RxBool isLoading = true.obs;
  final RxBool isLoadingReviews = false.obs;
  final RxList<dynamic> review = <dynamic>[].obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalReviews = 0.obs;

  // Provider data
  Rx<ProviderData?> providerData = Rx<ProviderData?>(null);

  // Services list with details
  RxList<ServiceDetail> services = <ServiceDetail>[].obs;

  @override
  void onInit() {
    super.onInit();
    getProviderInformation();
  }

  Future<void> getProviderInformation() async {
    final token = LocalStorage.token;
    print("Fetching provider information for service profile...");

    if (token.isEmpty) {
      Utils.errorSnackBar(0, "Token not found, please login again");
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final response = await ApiService.get(
          ApiEndPoint.getProvider,
          header: {"Authorization": "Bearer $token"}
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        providerData.value = ProviderData.fromJson(data);
        providerId = data['user']['_id'];

        // Populate all fields with API data
        populateProfileData(providerData.value!);
        await fetchReviews();

        print("Service Profile Data loaded successfully");
        print("Services loaded: ${services.length}");
        print("Work Photos: ${workPhotos.length}");

        isLoading.value = false;
        update();
      } else {
        isLoading.value = false;
        Utils.errorSnackBar(0, "Failed to load service profile data");
      }
    } catch (e) {
      isLoading.value = false;
      Utils.errorSnackBar(0, "Error: ${e.toString()}");
      print("Error fetching service profile data: $e");
    }
  }

  void populateProfileData(ProviderData data) {
    // Set about me
    if (data.aboutMe != null && data.aboutMe!.isNotEmpty) {
      aboutMe.value = data.aboutMe!;
    }

    // Set languages
    if (data.serviceLanguage != null && data.serviceLanguage!.isNotEmpty) {
      serviceLanguages.clear();
      serviceLanguages.addAll(data.serviceLanguage!);
    }

    // Set location
    if (data.primaryLocation != null && data.primaryLocation!.isNotEmpty) {
      primaryLocation.value = data.primaryLocation!;
    }

    // Set service distance
    if (data.serviceDistance != null) {
      serviceDistance.value = data.serviceDistance!;
    }

    // Set price per hour
    if (data.pricePerHour != null) {
      pricePerHour.value = data.pricePerHour!;
    }

    // Set work photos/service images
    if (data.serviceImages != null && data.serviceImages!.isNotEmpty) {
      workPhotos.clear();
      workPhotos.addAll(data.serviceImages!);
    }

    // Populate services list
    services.clear();
    if (data.services != null && data.services!.isNotEmpty) {
      for (var service in data.services!) {
        services.add(ServiceDetail(
          serviceName: service.category?.name ?? 'N/A',
          serviceType: service.subCategory?.name ?? 'N/A',
          price: service.price?.toString() ?? '0',
        ));
      }
    }

    print("Profile data populated:");
    print("- About Me: ${aboutMe.value.substring(0, aboutMe.value.length > 50 ? 50 : aboutMe.value.length)}...");
    print("- Languages: ${serviceLanguages.join(', ')}");
    print("- Location: ${primaryLocation.value}");
    print("- Service Distance: ${serviceDistance.value} km");
    print("- Price Per Hour: ${pricePerHour.value}");
    print("- Services: ${services.length}");
    print("- Work Photos: ${workPhotos.length}");

    update();
  }

  Future<void> fetchReviews() async {
    try {
      isLoadingReviews.value = true;
      // Get provider ID from your existing data
      String providerId = this.providerId;
      if (providerId.isEmpty) {
        print("❌ Provider ID is empty");
        return;
      }
      print("📡 Fetching reviews for provider: $providerId");
      final response = await ApiService.get(
        "review/$providerId",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );
      print("📡 Reviews Response Status: ${response.statusCode}");
      print("📦 Reviews Response Data: ${response.data}");
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        // Set review data
        review.value = data['reviews'] ?? [];
        averageRating.value = double.parse((data['averageRating'] ?? 0.0).toDouble().toStringAsFixed(2));
        totalReviews.value = data['totalReviews'] ?? 0;

        print("✅ Reviews loaded successfully - Total: ${totalReviews.value}");
        print("✅ Average Rating: ${averageRating.value}");
        print("✅ Reviews List Length: ${review.length}");
      } else {
        print("⚠️ Failed to load reviews");
      }
    } catch (e) {
      print("❌ Error fetching reviews: $e");
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // Get formatted languages string
  String getLanguagesString() {
    if (serviceLanguages.isEmpty) return 'Not specified';
    return serviceLanguages.join(', ');
  }

  // Get formatted price per hour
  String getFormattedPricePerHour() {
    if (pricePerHour.value == 0) return 'Not specified';
    return 'RSD ${pricePerHour.value.toStringAsFixed(0)}';
  }

  // Get formatted service distance
  String getFormattedServiceDistance() {
    if (serviceDistance.value == 0) return 'Not specified';
    return '${serviceDistance.value.toStringAsFixed(2)} KM';
  }

  void editServiceDetails() {
    // Navigate to edit screen
    Get.toNamed('/edit_service_screen');
  }
}

// Model class for service details
class ServiceDetail {
  final String serviceName;
  final String serviceType;
  final String price;

  ServiceDetail({
    required this.serviceName,
    required this.serviceType,
    required this.price,
  });
}