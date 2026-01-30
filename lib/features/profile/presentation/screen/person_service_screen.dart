import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/widget/home_custom_button.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'dart:io';
import '../../../../component/app_storage/show_image_full.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/service_profile_controller.dart';

class ServiceProfileScreen extends StatelessWidget {
  ServiceProfileScreen({super.key});

  final ServiceProfileController controller = Get.put(ServiceProfileController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              );
            }
        
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(
                      title: AppString.service_information,
                    ),
                    SizedBox(height: 18.h),
        
                    // About Me Section
                    CommonText(
                      text: AppString.about_me,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black400,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 12.h),
                    Obx(() => CommonText(
                      text: controller.aboutMe.value.isEmpty
                          ? AppString.noinformation
                          : controller.aboutMe.value,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black300,
                      textAlign: TextAlign.left,
                      maxLines: 10,
                    )),
        
                    SizedBox(height: 14.h),
        
                    // Languages
                    Obx(() => Row(
                      children: [
                        CommonText(
                          text: AppString.spoken,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black400,
                          textAlign: TextAlign.left,
                        ),
                        Expanded(
                          child: CommonText(
                            text: controller.getLanguagesString(),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                            textAlign: TextAlign.left,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    )),
        
                    SizedBox(height: 10.h),
        
                    // Location
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/location_icon.svg",
                          width: 24.w,
                          height: 24.h,
                          color: AppColors.black400,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: CommonText(
                            text: controller.primaryLocation.value.isEmpty
                                ? AppString.nolocation
                                : controller.primaryLocation.value,
                            fontSize: 12.sp,
                            color: AppColors.black300,
                            textAlign: TextAlign.start,
                            fontWeight: FontWeight.w400,
                            maxLines: 5,
                          ),
                        ),
                      ],
                    )),
        
                    SizedBox(height: 10.h),
        
                    // Service Distance
                    Obx(() => Row(
                      children: [
                        CommonText(
                          text: AppString.serviceDistance,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black400,
                          textAlign: TextAlign.left,
                        ),
                        CommonText(
                          text: controller.getFormattedServiceDistance(),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    )),
        
                    SizedBox(height: 10.h),
        
                    // Price Per Hour
                    /*Obx(() => Row(
                      children: [
                        CommonText(
                          text: AppString.priceperHour,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black400,
                          textAlign: TextAlign.left,
                        ),
                        CommonText(
                          text: controller.getFormattedPricePerHour(),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    )),*/
        
                    SizedBox(height: 20.h),
        
                    // Services Table
                    Obx(() => controller.services.isEmpty
                        ? Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.black300.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: CommonText(
                          text: AppString.service_available,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black300,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                        : _buildServicesTable()),
        
                    SizedBox(height: 14.h),
        
                    // My Work Photos Section
                    const CommonText(
                      text: AppString.work_details,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black400,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 6.h),
        
                    // Photo Grid
                    Obx(() => controller.workPhotos.isEmpty
                        ? Container(
                      height: 150.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.black300.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: CommonText(
                          text: AppString.workPhotNo,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black300,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                        : _buildPhotoGrid()),
        
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            );
          }),
        
          // Edit Service Details Button
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: CustomButton(
                    text: AppString.edit_service_button,
                    isSelected: true,
                    onTap: () {
                      Get.toNamed(AppRoutes.edit_service_screen);
                    })),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black300.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Table(
        border: TableBorder(
          verticalInside: BorderSide(color: AppColors.black300.withOpacity(0.3)),
          horizontalInside: BorderSide(color: AppColors.black300.withOpacity(0.3)),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CommonText(
                  text: AppString.service_text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CommonText(
                  text: AppString.service_type,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CommonText(
                  text: AppString.price_text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Data Rows - Dynamic from API
          ...controller.services.map((service) => TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CommonText(
                  text: service.serviceName,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black300,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CommonText(
                  text: service.serviceType,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black300,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CommonText(
                  text: "${service.price} RSD",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.9,
      ),
      itemCount: controller.workPhotos.length,
      itemBuilder: (context, index) {
        // Check if it's a URL or local file path
        bool isUrl = controller.workPhotos[index].startsWith('http') ||
            controller.workPhotos[index].startsWith('/');
        final imagePath = controller.workPhotos[index];

        return GestureDetector(
          onTap: () {
            // Open full-screen viewer
            List<String> imageList = controller.workPhotos.map((photo) {
              if (photo.startsWith('http/') || photo.startsWith('/')) {
                return ApiEndPoint.imageUrl + photo;
              } else {
                return photo; // local file path
              }
            }).toList();

            showDialog(
              context: context,
              builder: (_) => FullScreenImageViewer(images: imageList, initialIndex: index),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isUrl
                ? Image.network(
              ApiEndPoint.imageUrl+controller.workPhotos[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppString.image_available_now.tr,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
                : Image.file(
              File(controller.workPhotos[index]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}