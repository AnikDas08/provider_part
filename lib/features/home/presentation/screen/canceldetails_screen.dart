import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/pending_view_details_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/service_cancel.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_string.dart';
import '../../widget/home_custom_button.dart';

class CanceldetailsScreen extends StatelessWidget {
  const CanceldetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceCancelController());

    return Scaffold(
      body: SafeArea(
        child: Obx(
              () => controller.isLoading.value
              ? Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          )
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomAppBar(
                  title: AppString.view_details_text,
                  titleColor: AppColors.primaryColor,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 137.w,
                        height: 144.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.zero,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: controller.userImage.value.isNotEmpty &&
                              (controller.userImage.value
                                  .startsWith('http') ||
                                  controller.userImage.value
                                      .startsWith('/'))
                              ? Image.network(
                            ApiEndPoint.imageUrl +
                                controller.userImage.value,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/noImage.png",
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset(
                            "assets/images/noImage.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),
                      // Booking Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: controller.userName.value,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black400,
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/propetion_icon.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  color: AppColors.black400,
                                ),
                                SizedBox(width: 4.w),
                                CommonText(
                                  text: controller.serviceName.value,
                                  fontSize: 14.sp,
                                  color: AppColors.black400,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/day_icon.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  color: AppColors.black300,
                                ),
                                SizedBox(width: 4.w),
                                CommonText(
                                  text: controller.date.value,
                                  fontSize: 12.sp,
                                  color: AppColors.black300,
                                  fontWeight: FontWeight.w400,
                                ),
                                SizedBox(width: 12.w),
                                SvgPicture.asset(
                                  "assets/icons/time_icon.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  color: AppColors.black300,
                                ),
                                SizedBox(width: 4.w),
                                CommonText(
                                  text: controller.time.value,
                                  fontSize: 12.sp,
                                  color: AppColors.black300,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/location_icon.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  color: AppColors.black300,
                                ),
                                SizedBox(width: 4.w),
                                CommonText(
                                  text: controller.userLocation.value,
                                  fontSize: 12.sp,
                                  color: AppColors.black300,
                                  fontWeight: FontWeight.w400,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            CommonText(
                              text: "RSD: ${controller.amount.value}",
                              fontSize: 12.sp,
                              color: AppColors.black400,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}