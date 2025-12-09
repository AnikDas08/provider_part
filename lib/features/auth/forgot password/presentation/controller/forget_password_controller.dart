import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/auth/change_password/widget/popup_dialog.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../utils/app_utils.dart';

class ForgetPasswordController extends GetxController {
  /// Loading for forget password
  bool isLoadingEmail = false;

  /// Loading for Verify OTP

  bool isLoadingVerify = false;

  /// Loading for Creating New Password
  bool isLoadingReset = false;
  bool isLoadingWork = false;

  /// this is ForgetPassword Token , need to verification
  String forgetPasswordToken="";

  /// this is timer , help to resend OTP send time
  int start = 0;
  Timer? _timer;
  String time = "00:00";

  /// here all Text Editing Controller
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? "user@gmail.com" : '',
  );
  TextEditingController otpController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );
  TextEditingController confirmPasswordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );

  /// create Forget Password Controller instance
  static ForgetPasswordController get instance =>
      Get.put(ForgetPasswordController());

  @override
  void dispose() {
    startTimer();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// start Time for check Resend OTP Time

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    start = 180; // Reset the start value
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        start--;
        final minutes = (start ~/ 60).toString().padLeft(2, '0');
        final seconds = (start % 60).toString().padLeft(2, '0');

        time = "$minutes:$seconds";

        update();
      } else {
        _timer?.cancel();
      }
    });
  }

  /// Forget Password Api Call

  Future<void> forgotPasswordRepo() async {
    //Get.toNamed(AppRoutes.verifyEmail);
    //return;
    isLoadingEmail = true;
    update();

    Map<String, String> body = {"email": emailController.text};
    var response = await ApiService.post(
      ApiEndPoint.forgotPassword,
      body: body,
    );

    if (response.statusCode == 200) {
      Utils.successSnackBar(response.statusCode.toString(), response.message);
      Get.toNamed(AppRoutes.verifyEmail);
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }
    isLoadingEmail = false;
    update();
  }

  /// Verify OTP Api Call

  Future<void> verifyOtpRepo() async {
    //Get.toNamed(AppRoutes.createPassword);
    //return;
    isLoadingVerify = true;
    update();
    Map<String, String> body = {
      "email": emailController.text,
      "oneTimeCode": otpController.text,
    };
    var response = await ApiService.post(ApiEndPoint.verifyOtp, body: body,);

    if (response.statusCode == 200) {
      var data = response.data;
      forgetPasswordToken = data['data']['resetPasswordToken'] ?? "";
      Get.toNamed(AppRoutes.createPassword);
    } else {
      //Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoadingVerify = false;
    update();
  }

  /// Create New Password Api Call

  Future<void> resetPasswordRepo() async {
    isLoadingReset = true;
    update();

    Map<String, String> header = {
      "authorization": forgetPasswordToken, // or use Forget-password: forgetPasswordToken
    };

    Map<String, String> body = {
      "newPassword": passwordController.text,
      "confirmPassword": confirmPasswordController.text,
    };

    print("Sending Reset Header: $header");

    var response = await ApiService.post(
      ApiEndPoint.resetPassword,
      body: body,
      header: header,
    );
    print("kdljfd");

    if (response.statusCode == 200) {
      simpleDialog();
      emailController.clear();
      otpController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoadingReset = false;
    update();
  }
  Future<void> resetButton() async {
    //Get.toNamed(AppRoutes.verifyEmail);
    //return;
    isLoadingWork = true;
    update();

    Map<String, String> body = {"email": emailController.text};
    var response = await ApiService.post(
      ApiEndPoint.reset_otp,
      body: body,
    );

    if (response.statusCode == 200) {
      Get.toNamed(AppRoutes.verifyEmail);
      Get.snackbar(AppString.successful, AppString.successful_send_otp);
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }
    isLoadingWork = false;
    update();
  }
}
