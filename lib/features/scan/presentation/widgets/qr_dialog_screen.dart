import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/features/scan/presentation/widgets/review_scan_bottomsheet.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';


import '../../../home/widget/home_custom_button.dart';

showQrDialog() async {
  //final QRScannerController controller = Get.find<QRScannerController>();
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Image
            Image.asset(
              "assets/images/succes_image.png", // 👉 put your image in assets folder
              height: 100.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),

            // ✅ Title
           CommonText(
               text: AppString.appointment_successful,
             fontWeight:FontWeight.w500,
             maxLines: 2,
             fontSize: 22.sp,
             color: AppColors.black400,
           ),
            SizedBox(height: 30.h),

            // ✅ Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: CustomButton(text: AppString.cancel_button, isSelected: false, onTap: (){Get.back();})),
                SizedBox(width: 10,),
                Expanded(
                    child: CustomButton(
                        text: AppString.done_button,
                        isSelected: true,
                        onTap: (){
                          Get.back(); // Close the dialog first
                          showReviewBottomSheet();
                        }
                    )
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}