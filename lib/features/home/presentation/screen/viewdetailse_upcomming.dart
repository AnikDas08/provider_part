import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_string.dart';
import '../../widget/home_custom_button.dart';
import '../controller/upcoming_details_controller.dart';

class ViewDetailsUpcoming extends StatelessWidget {
  const ViewDetailsUpcoming({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpcomingViewDetailsController());

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
                          child: controller.userImage.isNotEmpty &&
                              (controller.userImage
                                  .startsWith('http') ||
                                  controller.userImage
                                      .startsWith('/'))
                              ? Image.network(
                            ApiEndPoint.imageUrl +
                                controller.userImage,
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
                              text: controller.userName,
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
                                  maxLines: 2,
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
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/booking_id_icon.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  color: AppColors.black300,
                                ),
                                CommonText(
                                  text: '${AppString.bookingid} ${controller.bookingId.value}',
                                  fontSize: 12.sp,
                                  color: AppColors.black300,
                                  fontWeight: FontWeight.w400,
                                ),
                                SizedBox(width: 12.w),
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
                                  text: controller.userLocation,
                                  fontSize: 12.sp,
                                  color: AppColors.black300,
                                  fontWeight: FontWeight.w400,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            CommonText(
                              text: "RSD :${controller.amount.value}",
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
                height: 30.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: AppString.cancel_button,
                        fontSize: 14,
                        height: 48,
                        isSelected: false,
                        onTap: () async {
                          // Show confirmation dialog
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: CommonText(
                                text: AppString.cancelBooking,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              content: CommonText(
                                maxLines: 4,
                                text:
                                AppString.cancleBookingSure,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        text: AppString.no_button,
                                        isSelected: false,
                                        onTap: () {
                                          Get.back();
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 25),
                                    Expanded(
                                      child: CustomButton(
                                        text: AppString.yes_button,
                                        isSelected: true,
                                        onTap: () async {
                                          Get.back(); // Close dialog
                                          await controller.cancelBooking();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12,),
                    Expanded(
                      child: CustomButton(
                        text: AppString.message_text,
                        fontSize: 18,
                        isSelected: true,
                        onTap: () async {
                          print("Chat id : 😍😍😍😍 ${controller.chatId}");
                          Get.toNamed(
                              AppRoutes.message,
                              parameters: {
                                "id":controller.chatId
                              },
                              arguments: {
                                "name":controller.userName,
                                "image":controller.userImage,
                              });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}