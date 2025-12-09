import 'package:get/get.dart';

class ServiceDetailsController extends GetxController {
  // Service provider data
  Map<String, dynamic> serviceProvider = {};

  // UI state
  bool isLoading = false;
  bool isFavorite = false;

  // Sample work photos
  List<String> workPhotos = [];

  // Sample reviews
  List<Map<String, dynamic>> reviews = [];

  @override
  void onInit() {
    super.onInit();
    _loadServiceDetails();
  }

  void _loadServiceDetails() {
    // Get data from arguments or load from API
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      serviceProvider = arguments;
    } else {
      // Sample data if no arguments provided
      serviceProvider = {
        "name": "Angle Mariomi",
        "service": "Haircut",
        "distance": "3km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "https://via.placeholder.com/400x200",
        "languages": "English, Russian, Serbian",
        "services": [
          {"name": "Hair Cut", "duration": "30 - 2hr", "price": "RSD 2500"},
          {"name": "Beard Care", "duration": "15 - 2hr", "price": "RSD 3000"},
        ],
        "about":
            "With 10 Years Of Experience In The Hair Styling Industry, I Am Passionate About Helping My Clients Feel Their Best Through Personalized Haircuts And Styling. Whether You're Looking For A Fresh Cut, A Bold New Look, Or Expert Styling Advice, I Provide Top-Notch Service With A Focus On Making Each Client Feel Confident And Unique.",
      };
    }

    _loadWorkPhotos();
    _loadReviews();
    update(); // Trigger UI update
  }

  void _loadWorkPhotos() {
    workPhotos = [
      "https://via.placeholder.com/150x150",
      "https://via.placeholder.com/150x150",
      "https://via.placeholder.com/150x150",
      "https://via.placeholder.com/150x150",
    ];
  }

  void _loadReviews() {
    reviews = [
      {
        "name": "Rahad Ullah",
        "rating": 5,
        "comment":
            "He Does A Great Job. I Had His Hair Cut A Few Days Ago. He Fulfilled All My Expectations I Always Praise Him.",
        "avatar": "https://via.placeholder.com/40",
      },
      {
        "name": "Rahad Ullah",
        "rating": 5,
        "comment":
            "He Does A Great Job. I Had His Hair Cut A Few Days Ago. He Fulfilled All My Expectations I Always Praise Him.",
        "avatar": "https://via.placeholder.com/40",
      },
    ];
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    update(); // Trigger UI update
    // Implement favorite functionality
  }

  void onBookNow() {
    // Navigate to booking screen
    // Get.toNamed(AppRoutes.booking, arguments: serviceProvider);
  }

  void onBackPressed() {
    Get.back();
  }

  void onAvailabilityTap() {
    // Show availability dialog or navigate to availability screen
  }
}
