import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../widgets/qr_dialog_screen.dart';

class QRScannerController extends GetxController {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  var isFlashOn = false.obs;
  var isScanning = true.obs;
  var scannedData = ''.obs;
  var selectedRating = 0.obs;
  var isProcessing = false.obs; // Add loading state
  var providerId = ''.obs;

  TextEditingController feedbackController = TextEditingController();
  TextEditingController barController = TextEditingController();

  @override
  void dispose() {
    controller?.dispose();
    feedbackController.dispose();
    barController.dispose();
    super.dispose();
  }

  void setRating(int rating) {
    selectedRating.value = rating;
  }

  Future<void> submitFeedback() async {
    // Validate rating
    if (selectedRating.value == 0) {
      Get.snackbar(
        AppString.error,
        "Please select a rating",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Show loading
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await ApiService.post(
        "review",
        body: {
          "providerId": providerId.value,
          "rating": selectedRating.value.toDouble(),
          "comment": feedbackController.text.trim(),
        },
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Close review bottom sheet
        Get.back();

        Get.snackbar(
          AppString.successful,
          "Review submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear fields
        selectedRating.value = 0;
        feedbackController.clear();
      } else {
        Get.snackbar(
          AppString.failed,
          "Failed to submit review",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog
      Get.back();

      print('Error submitting review: $e');
      Get.snackbar(
        AppString.error,
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isScanning.value && scanData.code != null && !isProcessing.value) {
        await processScannedCode(scanData.code!);
      }
    });
  }

  // Process scanned QR code or manual ID
  Future<void> processScannedCode(String code) async {
    if (isProcessing.value) return;

    isProcessing.value = true;
    isScanning.value = false;
    scannedData.value = code;

    // Vibrate on scan
    HapticFeedback.lightImpact();

    try {
      final response = await ApiService.patch(
        ApiEndPoint.completeOrder + code,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        // Only show dialog on success
        if (response.data != null && response.data['providerId'] != null) {
          providerId.value = response.data['providerId'];
        }
        showSuccessDialog();
      } else {
        Get.snackbar(
          AppString.failed,
          AppString.order_complete_failed,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Resume scanning after failure
        resumeScanning();
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar(
        AppString.error,
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Resume scanning after error
      resumeScanning();
    } finally {
      isProcessing.value = false;
    }
  }

  // Handle manual ID confirmation from TextField
  Future<void> confirmManualId() async {
    String userId = barController.text.trim();

    if (userId.isEmpty) {
      Get.snackbar(
        "Empty Field",
        AppString.enter_user,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Process the manual ID same as scanned code
    await processScannedCode(userId);

    // Clear the text field after processing
    if (isProcessing.value == false) {
      barController.clear();
    }
  }

  void showSuccessDialog() {
    showQrDialog();
  }

  void toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      isFlashOn.value = !isFlashOn.value;
    }
  }

  void resumeScanning() {
    isScanning.value = true;
    isProcessing.value = false;
    controller?.resumeCamera();
  }

  void pauseScanning() {
    isScanning.value = false;
    controller?.pauseCamera();
  }

  void scanFromGallery() {
    print('Scan from gallery functionality');
  }
}