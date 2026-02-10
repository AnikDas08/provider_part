import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/notifications/data/model/notification_model.dart';
import 'package:haircutmen_user_app/features/notifications/repository/notification_repository.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../services/api/api_service.dart';

class NotificationsController extends GetxController {
  /// Notification List
  List<NotificationModel> notifications = [];

  /// Notification Loading Bar
  bool isLoading = false;

  /// Notification more Data Loading Bar
  bool isLoadingMore = false;

  /// No more notification data
  bool hasNoData = false;

  /// page no here
  int page = 0;

  /// Notification Scroll Controller
  ScrollController scrollController = ScrollController();

  /// Rating value
  RxInt selectedRating = 0.obs;
  String? providerId;

  /// Feedback controller
  TextEditingController feedbackController = TextEditingController();

  /// Current provider ID for review
  String? currentProviderId;

  /// Loading state for review submission
  RxBool isSubmittingReview = false.obs;

  /// Notification More data Loading function
  void moreNotification() {
    // Clear existing listeners if any to prevent duplicates
    scrollController.removeListener(() {});

    scrollController.addListener(() {
      // Use a small buffer (e.g., 100 pixels from bottom) instead of exact maxScrollExtent
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
        if (!isLoadingMore && !hasNoData) {
          getNotificationsRepo(); // Call the same logic to keep it DRY
        }
      }
    });
  }
  readNotification()async{
    try{
      final response = await ApiService.patch(
        "notifications/read",
        header: {
          "Content-Type": "application/json",
        }
      );
    }
    catch(e){

    }
  }

  /// Notification data Loading function
  getNotificationsRepo() async {
    if (isLoadingMore || hasNoData) return;

    // Distinguish between first load and pagination
    if (notifications.isEmpty) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }
    update();

    page++;
    try {
      List<NotificationModel> list = await notificationRepository(page);

      if (list.isEmpty) {
        hasNoData = true;
      } else {
        // Logic to prevent duplicate items if API returns overlapping data
        notifications.addAll(list);
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading = false;
      isLoadingMore = false;
      update();
    }
  }

  /// Handle notification item click
  void onNotificationTap(NotificationModel item) {
    // Debug: check runtime type
    print(item.runtimeType); // Must be NotificationModel
    print("Id id ${item.title}");
    if (item.title == "Booking Completed Successfully") {
      providerId = item.referenceId?["_id"];
      print("Provider Id 😍 $providerId");
      if (providerId != null) {
        // You can show review dialog here
      } else {
        /*Get.snackbar(
          'Error',
          'Provider information not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );*/
      }
    }
  }

  /// Set rating
  void setRating(int rating) {
    selectedRating.value = rating;
  }

  /// Show review bottom sheet
  void showReviewBottomSheet(String providerId) {
    selectedRating.value = 0;
    feedbackController.clear();
    currentProviderId = providerId;
    // Show review dialog if needed
  }

  /// Submit review to API
  Future<void> submitReview() async {
    if (selectedRating.value == 0) {
      Get.snackbar(
        AppString.error,
        AppString.rating_show,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        AppString.error,
        AppString.review_writing,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmittingReview.value = true;

      Map<String, dynamic> body = {
        "providerId": providerId,
        "rating": selectedRating.value,
        "comment": feedbackController.text.trim(),
      };

      final response = await ApiService.post(
        "review",
        body: body,
        header: {'Content-Type': 'application/json'},
      );

      isSubmittingReview.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          AppString.successful,
          AppString.review_submited_successful,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        selectedRating.value = 0;
        feedbackController.clear();
        currentProviderId = null;
      } else {
        Get.snackbar(
          AppString.error,
          response.message ?? 'Failed to submit review',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isSubmittingReview.value = false;
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Controller instance
  static NotificationsController get instance =>
      Get.put(NotificationsController());

  /// On Init
  @override
  void onInit() {
    getNotificationsRepo();
    moreNotification();
    super.onInit();
  }

  /// Dispose controllers
  @override
  void onClose() {
    scrollController.dispose();
    feedbackController.dispose();
    super.onClose();
  }
}
