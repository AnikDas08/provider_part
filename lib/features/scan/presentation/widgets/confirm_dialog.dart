import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/scan/presentation/widgets/qr_dialog_screen.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../home/widget/home_custom_button.dart';
import '../controller/scan_controller.dart';

confirmDialog() async {
  final QRScannerController controller = Get.find<QRScannerController>();
  RxBool isChecked = true.obs; // ✅ for checkbox state

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(20.w),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Checkbox with text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // top align
              children: [
                // Checkbox কে compact করে একটু উপরে সরানো হলো
                Transform.translate(
                  offset: Offset(0, 0),
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: Checkbox(
                      value: isChecked.value,
                      onChanged: (v) => isChecked.value = v ?? false,
                      visualDensity: VisualDensity(vertical: -4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: AppColors.primaryColor,
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                Expanded(
                  child: CommonText(
                    text:
                    "Do you agree to let us use your photo or media for marketing and service improvement?",
                    fontSize: 14.sp,
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.w400,
                    maxLines: 5,
                    color: AppColors.black400,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h),

            // ✅ Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppString.cancel_button,
                    isSelected: false,
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    text: "Continue",
                    isSelected: true,
                    onTap: () {
                      if (isChecked.value) {
                        Get.back();
                        showQrDialog();
                      } else {
                        Get.snackbar("Consent Required",
                            "Please check the box before continuing",
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        )),
      );
    },
  );
}
