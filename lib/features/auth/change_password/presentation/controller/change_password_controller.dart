import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_services.dart';
import '../../../../../utils/app_utils.dart';
import '../../widget/popup_dialog.dart';

class ChangePasswordController extends GetxController {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  final token = LocalStorage.token;

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  ///  change password function

  Future<void> changePasswordRepo() async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    update();

    // For demo purposes, show success dialog directly
    // In production, uncomment the API call below
    await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
    //simpleDialog();

    //isLoading = false;
    //update();
    //return;

    // Production code (currently disabled for demo)
    Map<String, String> body = {
      "currentPassword": currentPasswordController.text,
      "newPassword": newPasswordController.text,
      "confirmPassword": newPasswordController.text,
    };
    var response = await ApiService.patch(
        ApiEndPoint.changePassword,
        body: body,
        header: {
          "Authorization": "Bearer $token"
        }
    );

    if (response.statusCode == 200) {
      Utils.successSnackBar(response.statusCode.toString(), response.message);

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      simpleDialog(); // Show success dialog
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }
    isLoading = false;
    update();
  }

  /// dispose Controller
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    // Clear the form state to avoid duplicate key issues
    formKey.currentState?.dispose();
    super.dispose();
  }
}
