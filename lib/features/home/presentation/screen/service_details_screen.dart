import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../component/button/common_button.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/service_details_controller.dart';
import '../widgets/review_card.dart';
import '../widgets/service_item_card.dart';
import '../widgets/work_photo_grid.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceDetailsController>(
      init: ServiceDetailsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with image and back button
                      _buildHeader(controller),
                      // Content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),

                            // Provider info
                            _buildProviderInfo(controller),

                            SizedBox(height: 20.h),

                            // Languages
                            _buildLanguages(controller),

                            SizedBox(height: 24.h),

                            // Service Fee section
                            _buildServiceFee(controller),

                            SizedBox(height: 24.h),

                            // About Me section
                            _buildAboutMe(controller),

                            SizedBox(height: 24.h),

                            // Work Photos section
                            _buildWorkPhotos(controller),

                            SizedBox(height: 24.h),

                            // Reviews section
                            _buildReviews(controller),

                            SizedBox(height: 100.h), // Space for bottom button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Book Now button
              _buildBottomButton(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ServiceDetailsController controller) {
    final provider = controller.serviceProvider;
    return Stack(
      children: [
        // Main image
        SizedBox(
          width: double.infinity,
          height: 200.h,
          child: CommonImage(
            imageSrc: provider["image"] ?? "",
            width: double.infinity,
            height: 200.h,
            fill: BoxFit.cover,
          ),
        ),

        // Gradient overlay
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black.withValues(alpha: 0.3),
                AppColors.transparent,
              ],
            ),
          ),
        ),

        // Back button and title
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.onBackPressed,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20.w,
                      color: AppColors.textColor,
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                CommonText(
                  text: AppString.viewProfile,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderInfo(ServiceDetailsController controller) {
    final provider = controller.serviceProvider;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              CommonText(
                text: provider["name"] ?? "",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
                textAlign: TextAlign.left,
              ),

              SizedBox(height: 8.h),

              // Service with icon
              Row(
                children: [
                  Icon(
                    Icons.content_cut,
                    size: 16.w,
                    color: AppColors.black600,
                  ),
                  SizedBox(width: 6.w),
                  CommonText(
                    text: provider["service"] ?? "",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black600,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Distance with icon
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.w,
                    color: AppColors.black600,
                  ),
                  SizedBox(width: 6.w),
                  CommonText(
                    text: "${AppString.distance} : ${provider["distance"] ?? ""}",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black600,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Rating
              Row(
                children: [
                  Icon(Icons.star, size: 16.w, color: Colors.amber),
                  SizedBox(width: 4.w),
                  CommonText(
                    text:
                        "${provider["rating"] ?? ""} (${provider["reviews"] ?? ""})",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Availability button
        GestureDetector(
          onTap: controller.onAvailabilityTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: CommonText(
              text: AppString.availability,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguages(ServiceDetailsController controller) {
    final provider = controller.serviceProvider;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.spoken,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 4.h),
        CommonText(
          text: provider["languages"] ?? "",
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryColor,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildServiceFee(ServiceDetailsController controller) {
    final provider = controller.serviceProvider;
    final services = provider["services"] as List<Map<String, dynamic>>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.availability,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 16.h),

        ...services.map((service) {
          return ServiceItemCard(
            serviceName: service["name"] ?? "",
            duration: service["duration"] ?? "",
            price: service["price"] ?? "",
          );
        }),
      ],
    );
  }

  Widget _buildAboutMe(ServiceDetailsController controller) {
    final provider = controller.serviceProvider;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.aboutMe,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 12.h),

        CommonText(
          text: provider["about"] ?? "",
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.black700,
          textAlign: TextAlign.left,
          maxLines: 10,
        ),
      ],
    );
  }

  Widget _buildWorkPhotos(ServiceDetailsController controller) {
    final photos = controller.workPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.workPhoto,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 16.h),

        WorkPhotoGrid(
          photos: photos,
          onViewAll: () {
            // Navigate to photo gallery
          },
        ),
      ],
    );
  }

  Widget _buildReviews(ServiceDetailsController controller) {
    final reviews = controller.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.review,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 16.h),

        ...reviews.map((review) {
          return ReviewCard(
            name: review["name"] ?? "",
            rating: review["rating"] ?? 0,
            comment: review["comment"] ?? "",
            avatarUrl: review["avatar"] ?? "",
          );
        }),
      ],
    );
  }

  Widget _buildBottomButton(ServiceDetailsController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: CommonButton(
          titleText: AppString.bookNow,
          onTap: controller.onBookNow,
          buttonRadius: 8.r,
          buttonHeight: 50.h,
        ),
      ),
    );
  }
}
