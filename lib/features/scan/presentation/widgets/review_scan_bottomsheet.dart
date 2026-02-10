import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../home/widget/home_custom_button.dart';
import '../controller/scan_controller.dart';

showReviewBottomSheet() {
  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final QRScannerController controller = Get.find<QRScannerController>();

      return SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top indicator line
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.black100,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
        
                SizedBox(height: 20.h),
        
                // Title
                Align(
                  alignment: Alignment.topLeft,
                  child: CommonText(
                    text: AppString.give_feedback,
                    fontSize: 18.sp,
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
        
                SizedBox(height: 20.h),
        
                // Star Rating
                Obx(() =>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => controller.setRating(index + 1),
                          child: Icon(
                            Icons.star,
                            size: 40.w,
                            color: index < controller.selectedRating.value
                                ? Color(
                                0xFFFFD700) // Golden color for selected stars
                                : AppColors
                                .black100, // Gray color for unselected stars
                          ),
                        );
                      }),
                    )),
        
                SizedBox(height: 20.h),
        
                // Feedback text field
                Align(
                  alignment: Alignment.centerLeft,
                  child: CommonText(
                    text: AppString.give_feedback,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                ),
        
                SizedBox(height: 8.h),
        
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black100),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: controller.feedbackController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: AppString.hint_type_here,
                      hintStyle: TextStyle(
                        color: AppColors.black200,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                  ),
                ),
        
                SizedBox(height: 30.h),
        
                // Confirm Button
                CustomButton(text: AppString.confirm_button, isSelected: true, onTap: (){
                  Get.back();
                }),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      );
    },
  );
}