import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../component/text/common_text.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../../utils/constants/app_string.dart';
import '../../../home/widget/home_custom_button.dart';

simpleDialog() async {
  // Store the current context before showing dialog
  final currentContext = Get.context!;

  await showDialog(
    context: currentContext,
    barrierDismissible: false,
    builder: (dialogContext) { // Use dialog's own context
      return WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          contentPadding: EdgeInsets.all(20.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Image
              Image.asset(
                "assets/images/succes_image.png",
                height: 100.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),

              // ✅ Title
              CommonText(
                text: AppString.password_change_now,
                textAlign: TextAlign.center,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                maxLines: 2,
              ),
              SizedBox(height: 30.h),

              // ✅ Button
              CustomButton(
                  text: AppString.back_to_login_button,
                  isSelected: true,
                  onTap: () {
                   Get.offAllNamed(AppRoutes.signIn);
                  }
              )
            ],
          ),
        ),
      );
    },
  );
}